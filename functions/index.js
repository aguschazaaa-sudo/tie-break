const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.onNotificationCreated = functions.firestore
    .document('notifications/{notificationId}')
    .onCreate(async (snapshot, context) => {
        const notification = snapshot.data();
        const targetUserId = notification.receiverId;

        console.log('New notification detected for user:', targetUserId);

        // 1. Get the target user's FCM token
        const userDoc = await admin.firestore().collection('users').doc(targetUserId).get();
        if (!userDoc.exists) {
            console.log('User document does not exist:', targetUserId);
            return null;
        }

        const userData = userDoc.data();
        const fcmToken = userData.fcmToken;

        if (!fcmToken) {
            console.log('No FCM token for user:', targetUserId);
            return null;
        }

        // 2. Build the message
        const message = {
            notification: {
                title: notification.title,
                body: notification.body,
            },
            token: fcmToken,
            data: {
                reservationId: notification.reservationId || '',
                type: notification.type || 'matchJoined',
            },
            // Android specific settings for high priority
            android: {
                priority: 'high',
                notification: {
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    channelId: 'high_importance_channel',
                },
            },
            // iOS specific settings
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
        };

        // 3. Send via FCM
        try {
            const response = await admin.messaging().send(message);
            console.log('Successfully sent message:', response);
            return response;
        } catch (error) {
            console.error('Error sending message:', error);
            return null;
        }
    });

exports.onMatchFull = functions.firestore
    .document('reservations/{reservationId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();
        const reservationId = context.params.reservationId;
        const notificationBatch = [];

        const newParticipants = newData.participantIds || [];
        const oldParticipants = oldData.participantIds || [];

        // Logic for match2vs2 (Full 4 players)
        if (newData.type === 'match2vs2') {
            // Check if it just became full (4 participants)
            if (newParticipants.length === 4 && oldParticipants.length < 4) {
                console.log(`Match full detected for match2vs2 ${reservationId}.`);
                // Send to all
                for (const userId of newParticipants) {
                    notificationBatch.push(
                        admin.firestore().collection('notifications').add({
                            receiverId: userId,
                            type: 'matchFull',
                            reservationId: reservationId,
                            title: '¡Partido confirmado!',
                            body: 'Se ha completado el cupo para tu partido.',
                            createdAt: admin.firestore.FieldValue.serverTimestamp(),
                            read: false,
                        })
                    );
                }
            }
        }
        // Logic for falta1 (Someone joined)
        else if (newData.type === 'falta1') {
            // Check if someone joined (participants count increased)
            if (newParticipants.length > oldParticipants.length) {
                // Check if the joined user is NOT the owner
                const joinedUserId = newParticipants.find(id => !oldParticipants.includes(id));

                if (joinedUserId && joinedUserId !== newData.userId) {
                    console.log(`User joined Falta1 match ${reservationId}. Treating as complete.`);

                    // Send to ALL participants (including owner and the one who joined)
                    for (const userId of newParticipants) {
                        notificationBatch.push(
                            admin.firestore().collection('notifications').add({
                                receiverId: userId,
                                type: 'matchFull',
                                reservationId: reservationId,
                                title: '¡Partido confirmado!',
                                body: 'Se ha completado el cupo para tu partido.',
                                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                                read: false,
                            })
                        );
                    }
                }
            }
        }

        if (notificationBatch.length > 0) {
            await Promise.all(notificationBatch);
            console.log(`Sent notifications for reservation ${reservationId}`);
            return true;
        }

        // Logic for Approved Reservation (status changed to approved)
        if (oldData.status !== 'approved' && newData.status === 'approved') {
            const ownerId = newData.userId;
            console.log(`Reservation ${reservationId} approved. Notifying owner ${ownerId}.`);

            await admin.firestore().collection('notifications').add({
                receiverId: ownerId,
                type: 'reservationApproved',
                reservationId: reservationId,
                title: '¡Reserva Aprobada!',
                body: 'Tu reserva ha sido confirmada.',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                read: false,
            });
            return true;
        }

        return null;
    });

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

// Cloud Function: Escucha actualizaciones de reservas para generar notificaciones
// Condiciones:
// - 2vs2: Se completa cuando team2 tiene 2 jugadores (segunda pareja se une)
// - Falta 1: Se completa cuando alguien más se suma (aunque no sean 4)
exports.onMatchFull = functions.firestore
    .document('reservations/{reservationId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();
        const reservationId = context.params.reservationId;
        const notificationBatch = [];

        // Usamos team1Ids y team2Ids en lugar de participantIds
        const newTeam1 = newData.team1Ids || [];
        const newTeam2 = newData.team2Ids || [];
        const oldTeam2 = oldData.team2Ids || [];

        // Todos los participantes actuales
        const allParticipants = [...newTeam1, ...newTeam2];

        // Lógica para match2vs2: se completa cuando team2 tiene 2 jugadores
        if (newData.type === 'match2vs2') {
            // Verificar si team2 acaba de completarse (pasó de <2 a 2)
            if (newTeam2.length === 2 && oldTeam2.length < 2) {
                console.log(`Match2vs2 completado: ${reservationId}. Team2 tiene 2 jugadores.`);

                // Notificar a todos los participantes
                for (const userId of allParticipants) {
                    notificationBatch.push(
                        admin.firestore().collection('notifications').add({
                            receiverId: userId,
                            type: 'matchFull',
                            reservationId: reservationId,
                            title: '¡Partido confirmado!',
                            body: 'Se ha completado el cupo para tu partido 2vs2.',
                            createdAt: admin.firestore.FieldValue.serverTimestamp(),
                            read: false,
                        })
                    );
                }
            }
        }
        // Lógica para falta1: usa participantIds (no teams)
        // Al unirse alguien, notificar al owner y participantes existentes
        // (NO notificar a quien se acaba de unir)
        else if (newData.type === 'falta1') {
            const newParticipants = newData.participantIds || [];
            const oldParticipants = oldData.participantIds || [];

            // Verificar si alguien nuevo se unió a participantIds
            if (newParticipants.length > oldParticipants.length) {
                // Encontrar quién se unió
                const joinedUserId = newParticipants.find(id => !oldParticipants.includes(id));

                // Solo notificar si el que se unió NO es el owner
                if (joinedUserId && joinedUserId !== newData.userId) {
                    console.log(`Falta1 completado: ${reservationId}. Nuevo jugador: ${joinedUserId}`);

                    // Construir lista de destinatarios: owner + participantes existentes
                    // (excluimos al que se acaba de unir, ya lo sabe)
                    const recipientIds = new Set();
                    recipientIds.add(newData.userId); // Owner siempre recibe
                    for (const pid of oldParticipants) {
                        recipientIds.add(pid); // Participantes previos
                    }
                    recipientIds.delete(joinedUserId); // No notificar al que se unió

                    for (const userId of recipientIds) {
                        notificationBatch.push(
                            admin.firestore().collection('notifications').add({
                                receiverId: userId,
                                type: 'matchJoined',
                                reservationId: reservationId,
                                title: '¡Jugador encontrado!',
                                body: 'Alguien se unió a tu partido Falta 1.',
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

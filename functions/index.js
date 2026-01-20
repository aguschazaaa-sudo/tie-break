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

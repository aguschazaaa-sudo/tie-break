// firebase-messaging-sw.js
// Service Worker requerido por Firebase Cloud Messaging para recibir
// notificaciones push en segundo plano (background) en la web.
// Este archivo debe residir en la raíz del directorio web/ para que
// el navegador lo registre correctamente con el scope adecuado.

// Importar los scripts de Firebase necesarios para messaging
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

// Inicializar Firebase con la configuración del proyecto
// Estos valores deben coincidir con los de firebase_options.dart (web)
firebase.initializeApp({
    apiKey: "AIzaSyDTdGKujoZbG_vO58ZS54k1JRkfYq_72OU",
    appId: "1:153521158347:web:f42f8188a2cfdf41e4034e",
    messagingSenderId: "153521158347",
    projectId: "red-social-ryb3mf",
    authDomain: "red-social-ryb3mf.firebaseapp.com",
    storageBucket: "red-social-ryb3mf.firebasestorage.app",
});

// Obtener la instancia de messaging para manejar mensajes en background
const messaging = firebase.messaging();

// Listener para mensajes recibidos mientras la app está en segundo plano.
// Aquí se puede personalizar la notificación que se muestra al usuario.
messaging.onBackgroundMessage((payload) => {
    console.log("[firebase-messaging-sw.js] Mensaje en background recibido:", payload);

    // Extraer título y cuerpo de la notificación del payload
    const notificationTitle = payload.notification?.title || "Tie Break";
    const notificationOptions = {
        body: payload.notification?.body || "",
        icon: "/icons/Icon-192.png", // Ícono de la app para la notificación
    };

    // Mostrar la notificación al usuario
    self.registration.showNotification(notificationTitle, notificationOptions);
});

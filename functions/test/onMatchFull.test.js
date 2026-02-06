const test = require('firebase-functions-test')();

// Define mock factory self-contained
jest.mock('firebase-admin', () => {
    const addMock = jest.fn().mockResolvedValue({ id: 'new-notification-id' });
    const collectionMock = jest.fn().mockReturnValue({ add: addMock });

    const firestoreMockInstance = {
        collection: collectionMock,
        doc: jest.fn().mockReturnThis(),
    };

    const firestoreFn = jest.fn(() => firestoreMockInstance);
    firestoreFn.FieldValue = {
        serverTimestamp: jest.fn().mockReturnValue('MOCK_TIMESTAMP'),
    };

    return {
        initializeApp: jest.fn(),
        firestore: firestoreFn,
        messaging: jest.fn().mockReturnValue({ send: jest.fn() }),
    };
});

const myFunctions = require('../index.js');
const admin = require('firebase-admin');

describe('onMatchFull', () => {
    afterAll(() => {
        test.cleanup();
    });

    it('should create notifications for all 4 participants when match becomes full', async () => {
        const wrapped = test.wrap(myFunctions.onMatchFull);

        const beforeData = {
            type: 'match2vs2',
            participantIds: ['user1', 'user2', 'user3'],
            userId: 'user1',
        };
        const afterData = {
            type: 'match2vs2',
            participantIds: ['user1', 'user2', 'user3', 'user4'],
            userId: 'user1',
        };

        const change = {
            before: { data: () => beforeData },
            after: { data: () => afterData },
        };

        const db = admin.firestore();
        const collectionSpy = db.collection;
        const colRef = collectionSpy('notifications');
        const addSpy = colRef.add;

        collectionSpy.mockClear();
        addSpy.mockClear();

        await wrapped(change, {
            params: { reservationId: 'res123' },
        });

        expect(collectionSpy).toHaveBeenCalledWith('notifications');
        expect(addSpy).toHaveBeenCalledTimes(4);
        expect(addSpy).toHaveBeenCalledWith(expect.objectContaining({
            receiverId: expect.stringMatching(/user[1-4]/),
            type: 'matchFull',
            reservationId: 'res123',
            title: '¡Partido confirmado!',
            body: 'Se ha completado el cupo para tu partido.',
        }));
    });

    it('should NOT create notifications if match was already full', async () => {
        const wrapped = test.wrap(myFunctions.onMatchFull);

        const beforeData = {
            type: 'match2vs2',
            participantIds: ['user1', 'user2', 'user3', 'user4'],
        };
        const afterData = {
            type: 'match2vs2',
            participantIds: ['user1', 'user2', 'user3', 'user4'],
        };

        const change = {
            before: { data: () => beforeData },
            after: { data: () => afterData },
        };

        const db = admin.firestore();
        const addSpy = db.collection('notifications').add;
        addSpy.mockClear();

        await wrapped(change, {
            params: { reservationId: 'res123' },
        });

        expect(addSpy).not.toHaveBeenCalled();
    });

    it('should create notifications when a user joins a Falta 1 match', async () => {
        const wrapped = test.wrap(myFunctions.onMatchFull);

        const beforeData = {
            type: 'falta1',
            participantIds: ['user1'], // Only owner
            userId: 'user1',
        };
        const afterData = {
            type: 'falta1',
            participantIds: ['user1', 'user2'], // New user joined
            userId: 'user1',
        };

        const change = {
            before: { data: () => beforeData },
            after: { data: () => afterData },
        };

        const db = admin.firestore();
        const collectionSpy = db.collection;
        const colRef = collectionSpy('notifications');
        const addSpy = colRef.add;

        collectionSpy.mockClear();
        addSpy.mockClear();

        await wrapped(change, {
            params: { reservationId: 'resFalta1' },
        });

        // Should notify both participants
        expect(collectionSpy).toHaveBeenCalledWith('notifications');
        expect(addSpy).toHaveBeenCalledTimes(2);

        expect(addSpy).toHaveBeenCalledWith(expect.objectContaining({
            receiverId: expect.stringMatching(/user[1-2]/),
            type: 'matchFull',
            reservationId: 'resFalta1',
            title: '¡Partido confirmado!',
            body: 'Se ha completado el cupo para tu partido.',
        }));
    });

    it('should create notification for owner when reservation is approved', async () => {
        const wrapped = test.wrap(myFunctions.onMatchFull);

        const beforeData = {
            type: 'normal',
            participantIds: [],
            userId: 'ownerUser',
            status: 'pending',
        };
        const afterData = {
            type: 'normal',
            participantIds: [],
            userId: 'ownerUser',
            status: 'approved',
        };

        const change = {
            before: { data: () => beforeData },
            after: { data: () => afterData },
        };

        const db = admin.firestore();
        const collectionSpy = db.collection;
        const colRef = collectionSpy('notifications');
        const addSpy = colRef.add;

        collectionSpy.mockClear();
        addSpy.mockClear();

        await wrapped(change, {
            params: { reservationId: 'resApproved' },
        });

        // Should notify ONLY owner
        expect(collectionSpy).toHaveBeenCalledWith('notifications');
        expect(addSpy).toHaveBeenCalledTimes(1);

        expect(addSpy).toHaveBeenCalledWith(expect.objectContaining({
            receiverId: 'ownerUser',
            type: 'reservationApproved',
            reservationId: 'resApproved',
            title: '¡Reserva Aprobada!',
            body: 'Tu reserva ha sido confirmada.',
        }));
    });
});

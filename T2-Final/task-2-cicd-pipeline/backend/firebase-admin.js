const admin = require('firebase-admin');

// Check if Firebase Admin is already initialized
if (admin.apps.length > 0) {
  console.log('Firebase Admin already initialized');
  module.exports = admin;
  return;
}

// Option 1: Using service account key file (for production)
try {
  const serviceAccount = require('./service-account-key.json');
  
  // Check if the service account has placeholder values
  if (serviceAccount.private_key_id === 'REPLACE_WITH_YOUR_PRIVATE_KEY_ID') {
    throw new Error('Service account key has placeholder values');
  }
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id
  });
  console.log('Firebase Admin initialized with service account key');
} catch (error) {
  console.log('Service account key not available or invalid:', error.message);
  
  // Option 2: Using environment variables (for development)
  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: 'test-b656c' // Your Firebase project ID
    });
    console.log('Firebase Admin initialized with application default credentials');
  } catch (initError) {
    console.log('Firebase Admin initialization failed:', initError.message);
    console.log('Please provide a valid service account key or set up application default credentials');
  }
}

module.exports = admin; 
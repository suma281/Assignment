import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getAnalytics } from 'firebase/analytics';

// Your Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAsxObghXXXXXXXXXXXXXesNuRg9hQs",
  authDomain: "test-b656c.firebaseapp.com",
  projectId: "test-b656c",
  storageBucket: "test-b656c.firebasestorage.app",
  messagingSenderId: "802045609010",
  appId: "1:8020456090XXXXXX10:web:05eXXXXXX885a578a82b",
  measurementId: "G-5ZXXXXXJZRF"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase Authentication and get a reference to the service
export const auth = getAuth(app);

// Initialize Analytics (only in browser environment)
let analytics = null;
if (typeof window !== 'undefined') {
  analytics = getAnalytics(app);
}

export { analytics };
export default app; 
# 🔥 Firebase Setup Guide

## 🚨 **Current Issue: "auth/invalid-credential" Error**

The error you're seeing means Firebase authentication isn't properly configured. Here's how to fix it:

## 📋 **Step-by-Step Setup**

### **1. Enable Firebase Authentication**

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `test-b656c` or Create a project
3. **Click "Authentication"** in the left sidebar
4. **Click "Get started"**
5. **Go to "Sign-in method" tab**
6. **Enable "Email/Password"** provider:
   - Click on "Email/Password"
   - Toggle the switch to **ON**
   - Click **"Save"**

### **2. Get Service Account Key (Required for Backend)**

1. **In Firebase Console**, go to **Project Settings** (gear icon)
2. **Go to "Service accounts" tab**
3. **Click "Generate new private key"**
4. **Click "Generate key"** - this downloads a JSON file
5. **Replace the placeholder file**:
   - Save the downloaded file as `backend/service-account-key.json`
   - Replace the placeholder content with your actual service account key

### **3. Test User Registration**

1. **Go to your app**: http://localhost:3000
2. **Click "Register here"** to go to registration page
3. **Create a new account** with email and password
4. **Check Firebase Console** → Authentication → Users
5. **You should see your registered user**

### **4. Test Login**

1. **Go to login page**: http://localhost:3000/login
2. **Use the credentials** you just registered
3. **Should successfully log in**

## 🔧 **Troubleshooting**

### **If you still get "auth/invalid-credential":**

1. **Check if user exists**:
   - Go to Firebase Console → Authentication → Users
   - Verify the user was created

2. **Check Firebase configuration**:
   - Verify the API key in `frontend/src/firebase.js` is correct
   - Make sure the project ID matches

3. **Check service account key**:
   - Ensure `backend/service-account-key.json` has real values
   - Not placeholder values

### **If backend authentication fails:**

1. **Check service account key**:
   - Make sure it's valid and not placeholder
   - Check the project ID matches

2. **Check Firebase Admin logs**:
   - Look at backend container logs
   - Should show "Firebase Admin initialized"

## 📁 **File Structure After Setup**

```
task-2-cicd-pipeline/
├── frontend/
│   └── src/
│       └── firebase.js          ✅ Updated with your config
├── backend/
│   ├── service-account-key.json ✅ Your actual service account key
│   ├── firebase-admin.js        ✅ Updated error handling
│   └── index.js                 ✅ Ready for authentication
└── ...
```

## 🎯 **What Should Work After Setup**

1. **User Registration**: Create new accounts
2. **User Login**: Log in with registered credentials
3. **Backend Authentication**: Protected endpoints work
4. **Dashboard**: Shows user data from backend

## 🚀 **Quick Test Commands**

```bash
# Test backend health
curl http://localhost:8000/health

# Test backend main endpoint
curl http://localhost:8000/

# Check container logs
docker-compose logs backend
docker-compose logs frontend
```

## 📞 **Need Help?**

If you're still having issues:

1. **Check Firebase Console** for any error messages
2. **Verify all configuration files** are updated
3. **Restart containers** after making changes:
   ```bash
   docker-compose down
   docker-compose up --build
   ``` 
# Getting Firebase Service Account Key for Backend

## 🔑 **Step-by-Step Guide**

### 1. Go to Firebase Console
- Visit: https://console.firebase.google.com/
- Select your project: **test-b656c**

### 2. Navigate to Service Accounts
- Click the **gear icon** (⚙️) next to "Project Overview"
- Go to **"Service accounts"** tab

### 3. Generate Service Account Key
- Click **"Generate new private key"**
- Click **"Generate key"**
- This will download a JSON file

### 4. Save the Key File
- Save the downloaded JSON file as `service-account-key.json`
- Place it in the `backend/` directory
- **IMPORTANT**: Never commit this file to git!

### 5. File Structure Should Look Like:
```
task-2-cicd-pipeline/
├── backend/
│   ├── service-account-key.json  ← Your downloaded file
│   ├── index.js
│   ├── firebase-admin.js
│   └── package.json
└── ...
```

## 🔒 **Security Notes**

- ✅ The file is already in `.gitignore`
- ✅ Never share this file publicly
- ✅ Keep it secure and private
- ✅ For production, use environment variables

## 🚀 **Next Steps**

After saving the service account key:

1. **Test Docker Compose** (already working):
   ```bash
   docker-compose up --build
   ```

2. **Deploy to Kubernetes**:
   ```bash
   cd k8s
   ./setup-firebase-secret.sh
   ./deploy.sh
   ```

## 📋 **What's Already Configured**

✅ **Frontend Firebase Config** - Updated with your credentials
✅ **Backend Firebase Admin** - Ready to use service account key
✅ **Kubernetes ConfigMap** - Updated with your project ID
✅ **Kubernetes Secret** - Ready for service account key
✅ **Docker Setup** - Working and tested

## 🎯 **Your Firebase Project Details**

- **Project ID**: test-b656c
- **Project Name**: test-b656c
- **Auth Domain**: test-b656c.firebaseapp.com
- **Storage Bucket**: test-b656c.firebasestorage.app

## 🔧 **Testing the Setup**

Once you have the service account key:

1. **Test Authentication**:
   - Go to http://localhost:3000
   - Try registering a new user
   - Try logging in

2. **Test Backend API**:
   - Backend health: http://localhost:8000/health
   - Protected endpoint: http://localhost:8000/api/data (requires auth)

3. **Check Firebase Console**:
   - Go to Authentication > Users
   - You should see your registered users 
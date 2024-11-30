import React, { useEffect, useState } from 'react';
import { onAuthStateChanged, getAuth, GoogleAuthProvider } from "firebase/auth";
import { doc, getDoc, getFirestore } from "firebase/firestore";
import { initializeApp } from "firebase/app";

const firebaseConfig = {
  apiKey: "AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI",
  authDomain: "vistafeedd.firebaseapp.com",
  projectId: "vistafeedd",
  storageBucket: "vistafeedd.appspot.com",
  messagingSenderId: "1025680611513",
  appId: "1:1025680611513:web:0f8c6be4228dba901ea368",
  measurementId: "G-ZFRR1BZQFV",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

export default function CabBookingLaptop() {
  const [user, setUser] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [userName, setUserName] = useState(null);
  const [userPfp, setUserPfp] = useState(null);

  // Monitor authentication state
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      if (currentUser) {
        setUser(currentUser.uid);
      } else {
        window.location.replace('/');
      }
    });

    return () => unsubscribe();
  }, []);

  // Fetch user details from Firestore
  useEffect(() => {
    if (!user) return;

    const fetchUserDetails = async () => {
      setLoading(true);
      try {
        const docRef = doc(db, "VistaRide User Details", user);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
          setUserName(docSnap.data()['User Name']);
          setUserPfp(docSnap.data()['Profile Picture']);
        } else {
          setError("No user data found.");
        }
      } catch (err) {
        setError(`Error fetching user data: ${err.message}`);
      } finally {
        setLoading(false);
      }
    };

    fetchUserDetails();
  }, [user]);

  useEffect(() => {
    document.title = 'Request a Ride with VistaRide';
  }, []);

  return (
    <div className="webbody">
      <div className="ehfjfv" style={{ display: 'flex', justifyContent: 'space-between' }}>
        <div className="hfejfw">VistaRide</div>
        <div
          className="hfejfw"
          style={{
            right: '100px',
            position: 'absolute',
            flexDirection: 'row',
            gap: '20px',
          }}
        >
          {loading ? (
            <div></div>
          ) : error ? (
            <div style={{ color: 'red' }}>{error}</div>
          ) : (
            <>
              <div className="dkf">{userName}</div>
              <div className="jnjvndv">
                <img
                  src={userPfp}
                  alt="User Profile"
                  height="45px"
                  width="45px"
                  style={{ borderRadius: '50%' }}
                />
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, doc, updateDoc } from 'firebase/firestore';
import { Link } from 'react-router-dom';
import { getAuth, onAuthStateChanged, sendPasswordResetEmail, signInWithEmailAndPassword } from 'firebase/auth';
// Firebase config
const firebaseConfig = {
    apiKey: "AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI",
    authDomain: "vistafeedd.firebaseapp.com",
    projectId: "vistafeedd",
    storageBucket: "vistafeedd.appspot.com",
    messagingSenderId: "1025680611513",
    appId: "1:1025680611513:web:40aeb5d0434d67ca1ea368",
    measurementId: "G-9V0M9VQDGM"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);
export default function AdminPage() {
    const [userid, setuserid] = useState('');
    useEffect(() => {
        onAuthStateChanged(auth, (user) => {
            if (user) {
                // User is signed in, see docs for a list of available properties
                // https://firebase.google.com/docs/reference/js/auth.user
                const uid = user.uid;
                setuserid(uid);
                // ...
            } else {
                // User is signed out
                // ...
            }
        });
    });
    const [admins, setadmins] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Admin Details'),
            (snapshot) => {
                const adminList = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (admin) => admin['uid'] != '6lpidsQ8s1PJyFo20kPSgm3okXG3'
                    );

                setadmins(adminList);
            },
            (error) => {
                console.error('Error fetching admins: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    const updateAdminApproval = async (isApproved, driverID) => {
        const docRef = doc(db, 'Admin Details', driverID);
        await updateDoc(docRef, { admin: !isApproved });
    };
    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">
                    Administrator Control
                </div>
                <div className="divider"></div>
                <div className="knjfnbnf">
                    <table style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse', border: '1px solid #e0e0e0' }}>
                        <thead style={{ fontWeight: '300', fontSize: '13px' }}>
                            <tr>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>User ID</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>First Name</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Last Name</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Email</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Password</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Email Verified</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Administrator</th>
                                <th style={{ fontWeight: '300', padding: '10px -10px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Date Of Signup</th>
                            </tr>
                        </thead>
                        <tbody style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse' }}>
                            {admins.map((admins, index) => (
                                <tr key={index}>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{admins['uid']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{admins['firstName']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{admins['lastName']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{admins['email']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><div
                                        style={{ marginTop: '5px', cursor: 'pointer' }}
                                        onClick={() => {
                                            console.log("Clicked on reset password for:", admins['email']);
                                            sendPasswordResetEmail(auth, admins['email'])
                                                .then(() => {
                                                    console.log("Password reset email sent successfully.");
                                                })
                                                .catch((error) => {
                                                    console.error("Error sending password reset email:", error.message, error.code);
                                                });
                                        }}
                                    >
                                        Reset Password
                                    </div>
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{admins['emailVerified'] ? 'Yes' : 'No'}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{admins['uid'] !== auth.currentUser.uid && (
                                        <div
                                            style={{
                                                cursor: 'pointer',
                                                display: 'flex',
                                                flexDirection: 'row',
                                                gap: '10px',
                                                fontSize: '10px',
                                            }}
                                            onClick={() => updateAdminApproval(admins['admin'], admins['uid'])}
                                        >
                                            {!admins['admin'] ? (
                                                <img
                                                    src="https://cdn-icons-png.flaticon.com/512/190/190411.png"
                                                    height={20}
                                                    width={20}
                                                    alt="Approve Admin"
                                                />
                                            ) : (
                                                <img
                                                    src="https://cdn-icons-png.flaticon.com/512/1828/1828843.png"
                                                    height={20}
                                                    width={20}
                                                    alt="Disapprove Admin"
                                                />
                                            )}
                                            {admins['admin'] ? 'Disapprove Admin' : 'Approve Admin'}
                                        </div>
                                    )}
                                    </td>
                                    <td
                                        style={{
                                            padding: '10px 20px',
                                            wordWrap: 'break-word',
                                            fontSize: '12px',
                                            border: '1px solid #e0e0e0',
                                        }}
                                    >
                                        {new Date(admins['DoJ'].seconds * 1000).toLocaleString('en-IN', {
                                            weekday: 'long',
                                            year: 'numeric',
                                            month: 'long',
                                            day: 'numeric',
                                            hour: '2-digit',
                                            minute: '2-digit',
                                            second: '2-digit',
                                        })}
                                    </td>

                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    )
}

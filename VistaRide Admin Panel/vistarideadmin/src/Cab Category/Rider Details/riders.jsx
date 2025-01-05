import React, { useEffect, useState } from 'react';
import { collection, onSnapshot, getFirestore } from 'firebase/firestore';
import { initializeApp } from 'firebase/app';
import { Link } from 'react-router-dom';

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

export default function Riders() {
    const [riders, setRiders] = useState([]);
    const [searchedText, setSearchedText] = useState('');

    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide User Details'),
            (snapshot) => {
                const riderList = snapshot.docs.map((doc) => doc.data());
                setRiders(riderList); // Update the state with rider data
            },
            (error) => {
                console.error('Error fetching riders: ', error);
            }
        );

        return () => unsubscribe();
    }, []);

    const handleInputChange = (event) => {
        setSearchedText(event.target.value.toLowerCase()); // update the state with typed content
    };

    const filteredRiders = riders.filter((rider) =>
        rider['User Name']?.toLowerCase().includes(searchedText) ||
        rider['Email Address']?.toLowerCase().includes(searchedText)
    );

    return (
        <div className="webbody" style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">Riders</div>
                <div className="divider"></div>
                <div className="jnjvnfjb">
                    <h4>Search:</h4>
                    <input
                        type="text"
                        placeholder="Search for riders..."
                        className="searchinput"
                        value={searchedText}
                        onChange={handleInputChange}
                    />
                    <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jfnvjnfb" onClick={() => setSearchedText('')}>
                            RESET
                        </div>
                    </Link>
                </div>
                <div className="knjfnbnf">
                    <table style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse', border: '1px solid #e0e0e0' }}>
                        <thead style={{ fontWeight: '300' }}>
                            <tr>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Profile Picture</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Rider Name</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Email</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>VistaMiles</th>
                            </tr>
                        </thead>
                        <tbody style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse' }}>
                            {filteredRiders.map((ride, index) => (
                                <tr key={index}>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        <img
                                            src={ride['Profile Picture'] || 'https://cdn-icons-png.flaticon.com/512/149/149071.png'}
                                            height="50px"
                                            width="50px"
                                            style={{ borderRadius: '50%' }}
                                            alt="Profile"
                                        />
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['User Name']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Email Address']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        {ride['Vistamiles'] > 0
                                            ? ride['Vistamiles'] > 1
                                                ? `${ride['Vistamiles']} VistaMiles`
                                                : `${ride['Vistamiles']} VistaMile`
                                            : '0 VistaMile'}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}

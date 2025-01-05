import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, getDoc, doc } from 'firebase/firestore';
import { Link } from 'react-router-dom';
import { jsPDF } from 'jspdf';

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

export default function Ridepage() {
    const [searchedText, setSearchedText] = React.useState('');
    const [totalrides, setTotalRides] = useState([]);
    const [drivernames, setDrivernames] = useState([]);
    const [ridernames, setRiderNames] = useState([]);
    const [ridercontact, setRiderContact] = useState([]);
    const [drivercontact, setDriverContact] = useState([]);

    const handleInputChange = (event) => {
        setSearchedText(event.target.value);
    };

    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Ride Details'),
            (snapshot) => {
                const rideslist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['Driver ID'] != null && rider['Ride Owner'] != null && rider['Driver ID'] != '' && rider['Ride Owner'] != ''
                    );
                setTotalRides(rideslist);

                const drivercontactArray = [];
                const driverNamesArray = [];
                const riderNamesArray = [];
                const riderContactArray = [];

                rideslist.forEach(async (ride) => {
                    const driverId = ride['Driver ID'];
                    const riderId = ride['Ride Owner'];

                    if (driverId) {
                        try {
                            const driverDocRef = doc(db, 'VistaRide Driver Details', driverId);
                            const driverDocSnap = await getDoc(driverDocRef);

                            if (driverDocSnap.exists()) {
                                const driverData = driverDocSnap.data();
                                drivercontactArray.push(driverData['Contact Number']);
                                driverNamesArray.push(driverData['Name']);
                            }
                        } catch (error) {
                            console.error('Error fetching driver data:', error);
                        }
                    }

                    if (riderId) {
                        try {
                            const riderDocRef = doc(db, 'VistaRide User Details', riderId);
                            const riderDocSnap = await getDoc(riderDocRef);

                            if (riderDocSnap.exists()) {
                                const riderData = riderDocSnap.data();
                                // console.log('Rider Data:', riderData);
                                riderContactArray.push(riderData['Email Address']);
                                riderNamesArray.push(riderData['User Name']);
                            }
                        } catch (error) {
                            console.error('Error fetching rider data:', error);
                        }
                    }
                });

                setDrivernames(driverNamesArray);
                setDriverContact(drivercontactArray);
                setRiderNames(riderNamesArray);
                setRiderContact(riderContactArray);
            },
            (error) => {
                console.error('Error fetching rides:', error);
            }
        );

        return () => unsubscribe();
    }, []);

    // Filter rides based on searchedText
    const filteredRides = totalrides.filter((ride, index) => {
        const searchText = searchedText.toLowerCase();
        const rideId = ride['Booking ID'] ? ride['Booking ID'].toLowerCase() : '';
        const riderName = ridernames[index] ? ridernames[index].toLowerCase() : '';
        const driverName = drivernames[index] ? drivernames[index].toLowerCase() : '';
        return (
            rideId.includes(searchText) ||
            riderName.includes(searchText) ||
            driverName.includes(searchText)
        );
    });

    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">Ride Details</div>
                <div className="divider"></div>
                <div className="jnjvnfjb">
                    <h4>Search:</h4>
                    <input
                        type="text"
                        placeholder="Search for rides..."
                        className='searchinput'
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
                    <table style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse', border: '2px solid #e0e0e0' }}>
                        <thead style={{ fontWeight: '300' }}>
                            <tr style={{ fontSize: '12px', borderBottom: '2px solid #e0e0e0' }}>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Ride ID</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Rider Name - Rider ID</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver Name - Driver ID</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Vehicle Category</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Rider Contact Number</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver Contact Number</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Pickup Location</th>
                                <th style={{ fontWeight: '300', padding: '10px -10px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Drop Location</th>
                                <th style={{ fontWeight: '400', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Ride Status</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Fare</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Trip Distance - Trip Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filteredRides.map((ride, index) => (
                                <tr key={index} style={{ borderBottom: '1px solid #e0e0e0' }}>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Booking ID']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ridernames[index]} - ({ride['Ride Owner']})</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{drivernames[index]} - ({ride['Driver ID']})</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Cab Category']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ridercontact[index]}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{drivercontact[index]}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Pickup Location']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Drop Location']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', color: ride['Ride Accepted'] ? 'green' : !ride['Ride Accepted'] && ride['Ride Completed'] ? 'green' : 'red', border: '1px solid #e0e0e0' }}>
                                        {ride['Ride Accepted'] ? 'Ongoing' : !ride['Ride Accepted'] && ride['Ride Completed'] ? 'Completed' : 'Cancelled'}
                                        <br></br><br />
                                         {ride['Ride Accepted']?(<a href={`/track/${ride['Booking ID']}`} onClick={localStorage.setItem('rideID',ride['Booking ID'])} target="_blank">Track Ride</a>):<></>}
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>₹{ride['Fare']} ({ride['Cash Payment']?'Cash':'Online'})</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Travel Distance']} - {ride['Travel Time']}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}

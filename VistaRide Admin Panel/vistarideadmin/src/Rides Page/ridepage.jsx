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
    const handleInputChange = (event) => {
        setSearchedText(event.target.value); // update the state with typed content
    };
    const [totalrides, settotalrides] = useState([]);
    const [drivernames, setDrivernames] = useState([]); // Store driver details in an array
    const [ridernames, setridernames] = useState([]);
    const [ridercontact, setridercontact] = useState([]);
    const [drivercontact, setdrivercontact] = useState([]);
    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Ride Details'),
            (snapshot) => {
                const rideslist = snapshot.docs
                    .map((doc) => doc.data())
                    .filter(
                        (rider) => rider['Driver ID'] != null && rider['Ride Owner'] != null && rider['Driver ID'] != '' && rider['Ride Owner'] != ''
                    ); // Only drivers that are online and available

                settotalrides(rideslist); // Update the state with ride data
                console.log('Rides', rideslist);

                // Fetch the driver's name for each ride in the rideslist
                const drivercontactArray = [];
                const driverNamesArray = []; // Initialize an empty array for storing driver names
                const driverMap = {}; // Object to map driverId to driverName
                const riderNamesArray = []; // Initialize an empty array for storing driver names
                const riderContactArray = [];
                const riderMap = {}; // Object to map driverId to driverName
                rideslist.forEach(async (ride) => {
                    const driverId = ride['Driver ID'];
                    if (driverId) {
                        // Fetch the driver's name from VistaRide Driver Details collection
                        try {
                            const driverDocRef = doc(db, 'VistaRide Driver Details', driverId);
                            const driverDocSnap = await getDoc(driverDocRef);

                            if (driverDocSnap.exists()) {
                                const driverData = driverDocSnap.data();

                                const driverName = driverData['Name']; // Assuming the driver's name is stored in the 'Name' field
                                const driverContact = driverData['Contact Number'];
                                drivercontactArray.push(driverContact);
                                driverNamesArray.push(driverName);
                                // Store driver name in the map
                                driverMap[driverId] = driverName;

                                // console.log('Driver Data', drivercontactArray);
                                // Once all names are fetched, update the state
                                setDrivernames(driverNamesArray);
                                setdrivercontact(drivercontactArray);
                            } else {
                                console.log('No such driver found for ID:', driverId);
                            }
                        } catch (error) {
                            console.error('Error fetching driver name: ', error);
                        }
                    }
                });
                rideslist.forEach(async (ride) => {
                    const riderID = ride['Ride Owner'];
                    if (riderID) {
                        // Fetch the driver's name from VistaRide Driver Details collection
                        try {
                            const driverDocRef = doc(db, 'VistaRide User Details', riderID);
                            const driverDocSnap = await getDoc(driverDocRef);

                            if (driverDocSnap.exists()) {
                                const driverData = driverDocSnap.data();

                                const riderName = driverData['User Name']; // Assuming the driver's name is stored in the 'Name' field
                                const riderContact = driverData['Email Address'];
                                riderNamesArray.push(riderName);
                                riderContactArray.push(riderContact);
                                // Store driver name in the map
                                riderMap[riderID] = riderName;
                                // console.log('Driver Data', driverNamesArray);
                                // Once all names are fetched, update the state
                                setridernames(riderNamesArray);
                                setridercontact(riderContactArray);
                            } else {
                                console.log('No such driver found for ID:', riderID);
                            }
                        } catch (error) {
                            console.error('Error fetching driver name: ', error);
                        }
                    }
                });
            },
            (error) => {
                console.error('Error fetching rides: ', error);
            }
        );

        // Cleanup listener on unmount
        return () => unsubscribe();
    }, []);
    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">
                    Ride Details
                </div>
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
                            {totalrides.map((ride, index) => (
                                <tr key={index} style={{ borderBottom: '1px solid #e0e0e0' }}>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Booking ID']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ridernames[index]} - ({ride['Ride Owner']})</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{drivernames[index]} - ({ride['Driver ID']})</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><Link style={{ textDecoration: 'none' }}> {ride['Cab Category']}</Link></td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><Link style={{ textDecoration: 'none', color: 'black' }}> {ridercontact[index]}</Link></td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><Link style={{ textDecoration: 'none', color: 'black' }}> {drivercontact[index]}</Link></td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Pickup Location']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Drop Location']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', color: ride['Ride Accepted'] ? 'green' : !ride['Ride Accepted'] && ride['Ride Completed'] ? 'green' : 'red', border: '1px solid #e0e0e0' }}>
                                        {ride['Ride Accepted'] ? 'Ongoing' : !ride['Ride Accepted'] && ride['Ride Completed'] ? 'Completed' : 'Cancelled'}
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>₹{ride['Fare']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Travel Distance']} - {ride['Travel Time']}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>

                </div>
            </div>
        </div>
    )
}

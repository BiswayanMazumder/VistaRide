import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, Marker } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot, doc, updateDoc } from 'firebase/firestore';
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

export default function Drivers() {
    const [drivers, setDrivers] = useState([]);
    const [searchedText, setSearchedText] = useState('');

    const updateDriverApproval = async (isApproved, driverID) => {
        const docRef = doc(db, 'VistaRide Driver Details', driverID);
        await updateDoc(docRef, { Blocked: !isApproved });
    };

    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'VistaRide Driver Details'),
            (snapshot) => {
                const driverList = snapshot.docs.map((doc) => doc.data());
                setDrivers(driverList); // Update the state with driver data
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        return () => unsubscribe();
    }, []);

    const handleInputChange = (event) => {
        setSearchedText(event.target.value); // update the state with typed content
    };

    const filteredDrivers = drivers.filter((driver) => {
        return (
            driver['Name'].toLowerCase().includes(searchedText.toLowerCase()) ||
            driver['Email Address'].toLowerCase().includes(searchedText.toLowerCase()) ||
            driver['Car Category'].toLowerCase().includes(searchedText.toLowerCase()) ||
            driver['Car Name'].toLowerCase().includes(searchedText.toLowerCase()) ||
            driver['Contact Number'].toLowerCase().includes(searchedText.toLowerCase())
        );
    });

    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">
                    Drivers
                </div>
                <div className="divider"></div>
                <div className="jnjvnfjb">
                    <h4>Search:</h4>
                    <input
                        type="text"
                        placeholder="Search for drivers"
                        className='searchinput'
                        value={searchedText}
                        onChange={handleInputChange}
                    />
                    {/* <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jfnvjnfb">
                            SEARCH
                        </div>
                    </Link> */}
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
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver Name</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Email</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Vehicle Category-Name</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Contact Number</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Total Trips Done</th>
                                <th style={{ fontWeight: '300', padding: '10px -10px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver Status</th>
                                <th style={{ fontWeight: '400', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Driver Location</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Actions</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Ratings</th>
                            </tr>
                        </thead>
                        <tbody style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse' }}>
                            {filteredDrivers.map((ride, index) => (
                                <tr key={index}>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}><img src={ride['Profile Picture'] == null || ride['Profile Picture'] == '' ? 'https://cdn-icons-png.flaticon.com/512/149/149071.png' : ride['Profile Picture']} height={'50px'} width={'50px'} style={{ borderRadius: '50%' }}></img></td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Name']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Email Address']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        {ride['Car Category']} - {ride['Car Name']} ({ride['Car Number Plate']})
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        <a href={`tel:${ride['Contact Number']}`}>{ride['Contact Number']}</a>
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        {ride['Rides Completed']?.length>0?`${ride['Rides Completed']?.length} trips completed`:`${0} trips completed`}
                                    </td>

                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0', color: ride['Driver Online'] && ride['Driver Avaliable'] ? 'green' : ride['Driver Online'] && ride['Driver Avaliable'] === false ? 'grey' : 'red', fontWeight: ride['Driver Online'] && ride['Driver Avaliable'] ? '600' : ride['Driver Online'] && ride['Driver Avaliable'] === false ? '600' : 'normal' }}>
                                        {ride['Driver Online'] && ride['Driver Avaliable'] ? 'Online' : ride['Driver Online'] && ride['Driver Avaliable'] === false ? 'In a ride' : 'Offline'}
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        <a href={`https://www.google.com/maps?q=${ride['Current Latitude']},${ride['Current Longitude']}`} target="_blank">Locate Driver</a>
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        <div onClick={() => updateDriverApproval(ride['Blocked'], ride['Driver ID'])} style={{ cursor: 'pointer', display: 'flex', flexDirection: 'row', gap: '10px', fontSize: '10px' }}>
                                            {ride['Blocked'] ? (<img src='https://cdn-icons-png.flaticon.com/512/190/190411.png' height={20} width={20} />) : (<img src='   https://cdn-icons-png.flaticon.com/512/1828/1828843.png ' //approved driver
                                                height={20} width={20}
                                            ></img>)}
                                            {!ride['Blocked'] ? 'Block Driver' : 'Unblock Driver'}
                                        </div>
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0', fontWeight: ride['Rating'] > 3 ? '600' : '500', color: ride['Rating'] < 3 ? 'red' : 'green' }}>
                                        {ride['Rating'] == null ? NaN : ride['Rating']}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                    <br /><br />
                </div>
            </div>
        </div>
    );
}

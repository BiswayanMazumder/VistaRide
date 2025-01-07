import React, { useEffect, useState } from 'react';
import { initializeApp } from 'firebase/app';
import { collection, getFirestore, onSnapshot } from 'firebase/firestore';
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

export default function Servicable_Locations() {
    const [location, setLocation] = useState([]);
    const [searchTerm, setSearchTerm] = useState("");

    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Servicable Locations'),
            (snapshot) => {
                const locationlist = snapshot.docs.map((doc) => doc.data());
                setLocation(locationlist);
            },
            (error) => {
                console.error('Error fetching drivers: ', error);
            }
        );

        return () => unsubscribe();
    }, []);

    // Function to convert country code to country name using Intl.DisplayNames
    const getCountryNameFromCode = (countryCode) => {
        const displayNames = new Intl.DisplayNames(['en'], { type: 'region' });
        return displayNames.of(countryCode) || countryCode;  // Returns the country name or the code if not found
    };

    // Filter locations based on the search term
    const filteredLocations = location.filter((ride) => {
        const cityName = ride['citySelected'].toLowerCase();
        const countryName = getCountryNameFromCode(ride['Country'].toUpperCase()).toLowerCase();
        const term = searchTerm.toLowerCase();

        // Check if the search term matches the city or country
        return cityName.includes(term) || countryName.includes(term);
    });

    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv" >
                    Added Locations
                </div>
                <div className="divider"></div>
                <div className="jnjvnfjb">
                    <h4>Search:</h4>
                    <input
                        type="text"
                        placeholder="Search for city or country..."
                        className='searchinput'
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)} // Update the search term as the user types
                    />
                    <Link style={{ textDecoration: 'none', color: 'black' }}>
                        <div className="jfnvjnfb">
                            RESET
                        </div>
                    </Link>
                </div>
                <div className="knjfnbnf">
                    <table style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse', border: '1px solid #e0e0e0', fontWeight: '12px' }}>
                        <thead style={{ fontWeight: '300' }}>
                            <tr>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Location ID</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>City Name</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Country</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Longitude Range</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Latitude Range</th>
                                <th style={{ fontWeight: '300', padding: '10px 20px', wordWrap: 'break-word', textAlign: 'left', border: '1px solid #e0e0e0' }}>Date Of Adding</th>
                            </tr>
                        </thead>
                        <tbody style={{ width: '100%', tableLayout: 'fixed', borderCollapse: 'collapse' }}>
                            {filteredLocations.map((ride, index) => (
                                <tr key={index}>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['id']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['citySelected']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        {getCountryNameFromCode(ride['Country'].toUpperCase())}
                                    </td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Longitude_Range']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>{ride['Latitude_Range']}</td>
                                    <td style={{ padding: '10px 20px', wordWrap: 'break-word', fontSize: '12px', border: '1px solid #e0e0e0' }}>
                                        {new Date(ride['dateCreated']).toLocaleString('en-US', {
                                            weekday: 'long',
                                            year: 'numeric',
                                            month: 'long',
                                            day: 'numeric',
                                            hour: '2-digit',
                                            minute: '2-digit',
                                            second: '2-digit'
                                        })}
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

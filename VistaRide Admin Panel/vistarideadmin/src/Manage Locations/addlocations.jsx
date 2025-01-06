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

export default function Addlocations() {
    return (
        <div className='webbody' style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">
                    Add Locations
                </div>
                <div className="divider"></div>
                <div className="knjfnbnf" style={{ display: 'flex', flexDirection: 'row', position: 'relative', width: '90%', height: '100%' }}>
                    <div className="ndvmnfmnf" style={{ position: 'relative', width: '60%', height: '100%', display: 'flex', flexDirection: 'column' }}>
                        <div className="nnfnjnfg" style={{ display: 'flex', flexDirection: 'row' }}>
                            Location Name
                            <div style={{ color: 'red', fontWeight: '600' }}>
                                *
                            </div>
                        </div>
                        <input type="text" className='jjdhfhgfj' placeholder='Search Any Location' />
                        <div className="nnfnjnfg" style={{ display: 'flex', flexDirection: 'row', marginTop: '30px' }}>
                            Country
                            <div style={{ color: 'red', fontWeight: '600' }}>
                                *
                            </div>
                        </div>
                        <select className="jjdhfhgfj" placeholder="Select Country">
                            <option value="" disabled selected>
                                Select a Country
                            </option>
                            {[
                                "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda",
                                "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas",
                                "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize",
                                "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil",
                                "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia",
                                "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China",
                                "Colombia", "Comoros", "Congo (Congo-Brazzaville)", "Costa Rica", "Croatia",
                                "Cuba", "Cyprus", "Czechia (Czech Republic)", "Denmark", "Djibouti",
                                "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador",
                                "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini (fmr. Swaziland)",
                                "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia",
                                "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea",
                                "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hungary",
                                "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy",
                                "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea (North)",
                                "Korea (South)", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon",
                                "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg",
                                "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands",
                                "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco",
                                "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar (Burma)",
                                "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua",
                                "Niger", "Nigeria", "North Macedonia", "Norway", "Oman", "Pakistan", "Palau",
                                "Palestine State", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines",
                                "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis",
                                "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino",
                                "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles",
                                "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands",
                                "Somalia", "South Africa", "South Sudan", "Spain", "Sri Lanka", "Sudan",
                                "Suriname", "Sweden", "Switzerland", "Syria", "Tajikistan", "Tanzania", "Thailand",
                                "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey",
                                "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates",
                                "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu",
                                "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"
                            ].map((country, index) => (
                                <option key={index} value={country}>
                                    {country}
                                </option>
                            ))}
                        </select>

                    </div>
                    <div className="ndvmnfmnf" style={{ position: 'relative', width: '40%', height: '100%' }}>

                    </div>
                </div>
            </div>
        </div>
    )
}

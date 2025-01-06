import React, { useState } from 'react';
import { LoadScript, Autocomplete } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

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
    const [selectedCountry, setSelectedCountry] = useState('in'); // Default country is India ('in' is the ISO code)
    const [city, setCity] = useState('');
    const [autocomplete, setAutocomplete] = useState(null);

    const handleCountryChange = (event) => {
        setSelectedCountry(event.target.value);
        setCity(''); // Reset city when country changes
    };

    const handleCitySelect = () => {
        if (autocomplete) {
            const place = autocomplete.getPlace();
            setCity(place.name); // Extracts the city name
        }
    };

    const handleLoad = (autocompleteInstance) => {
        setAutocomplete(autocompleteInstance);
    };

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
                        <LoadScript
                            googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM"
                            libraries={['places']}
                        >
                            <Autocomplete
                                onLoad={handleLoad}
                                onPlaceChanged={handleCitySelect}
                                options={{
                                    types: ['(cities)'], // Restrict to city types
                                    componentRestrictions: { country: selectedCountry }, // Restrict to the selected country
                                }}
                            >
                                <input
                                    type="text"
                                    className='jjdhfhgfj'
                                    placeholder='Search Any Location'
                                    value={city}
                                    onChange={(e) => setCity(e.target.value)}

                                />
                            </Autocomplete>
                        </LoadScript>
                        <div className="nnfnjnfg" style={{ display: 'flex', flexDirection: 'row', marginTop: '30px' }}>
                            Country
                            <div style={{ color: 'red', fontWeight: '600' }}>
                                *
                            </div>
                        </div>
                        <select
                            className="jjdhfhgfj"
                            placeholder="Select Country"
                            value={selectedCountry}
                            onChange={handleCountryChange}
                        >
                            {/* <option value="" disabled>
                                Select a Country
                            </option> */}
                            {[
                                { name: "Afghanistan", code: "af" },
                                { name: "Albania", code: "al" },
                                { name: "India", code: "in" },
                                { name: "United States", code: "us" },
                                { name: "United Kingdom", code: "gb" },
                                // Add other countries as needed
                            ].map((country, index) => (
                                <option key={index} value={country.code}>
                                    {country.name}
                                </option>
                            ))}
                        </select>
                        <div className="nnfnjnfg" style={{ display: 'flex', flexDirection: 'row', marginTop: '30px' }}>
                            Location Type
                            <div style={{ color: 'red', fontWeight: '600' }}>
                                *
                            </div>
                        </div>
                        <select
                            className="jjdhfhgfj"
                            placeholder="Select Option"
                        >
                            <option value="Pickup">Pickup</option>
                            <option value="Drop">Drop</option>
                        </select>

                    </div>
                    <div className="ndvmnfmnf" style={{ position: 'relative', width: '40%', height: '100%' }}></div>
                </div>
            </div>
        </div>
    );
}

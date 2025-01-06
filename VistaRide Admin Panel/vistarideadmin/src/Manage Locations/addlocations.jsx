import React, { useState } from 'react';
import { LoadScript, Autocomplete, GoogleMap, Circle } from '@react-google-maps/api';
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
    const mapOptions = {
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };
    const [coordinates, setCoordinates] = useState(null); // Store city coordinates
    const [autocomplete, setAutocomplete] = useState(null);

    const handleCountryChange = (event) => {
        setSelectedCountry(event.target.value);
        setCity(''); // Reset city when country changes
        setCoordinates(null); // Clear map when country changes
    };

    const handleCitySelect = () => {
        if (autocomplete) {
            const place = autocomplete.getPlace();
            if (place.geometry) {
                const location = place.geometry.location;
                const lat = location.lat();
                const lng = location.lng();

                // Log the latitude and longitude
                console.log(`Selected City: ${place.name}, Latitude: ${lat}, Longitude: ${lng}`);

                setCity(place.name); // Set the city name
                setCoordinates({ lat, lng }); // Set the city coordinates
            } else {
                console.error('No geometry information available for the selected place.');
            }
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
                    <div className="ndvmnfmnf" style={{ position: 'relative', width: '40%', height: '100%', display: 'flex', flexDirection: 'column' }}>
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
                    <div className="ndvmnfmnf" style={{ position: 'relative', width: '60%', height: '100%' }}>
                        <LoadScript googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM" libraries={['places']}>
                            <GoogleMap
                                center={coordinates || { lat: 20.5937, lng: 78.9629 }} // Default to India if no city is selected
                                zoom={coordinates ? 12 : 4} // Zoom in if coordinates are available, else zoom out for country view
                                mapContainerStyle={{ width: '100%', height: '100%' }}
                                options={mapOptions}
                            >
                                {coordinates && (
                                    <Circle
                                        center={coordinates}
                                        radius={5000} // Radius in meters
                                        options={{
                                            fillColor: '#3498db',
                                            fillOpacity: 0.2,
                                            strokeColor: '#3498db',
                                            strokeOpacity: 0.8,
                                            strokeWeight: 2,
                                        }}
                                    />
                                )}
                            </GoogleMap>
                        </LoadScript>
                    </div>
                </div>
            </div>
        </div>
    );
}

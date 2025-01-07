import React, { useEffect, useState } from 'react';
import { GoogleMap, LoadScript, HeatmapLayer, Circle } from '@react-google-maps/api';
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, onSnapshot } from 'firebase/firestore';

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

export default function Heatview() {
    const [rides, setRides] = useState([]);
    const [heatmapData, setHeatmapData] = useState([]);
    const [loading, setLoading] = useState(true);
    const [mapCenter, setMapCenter] = useState({ lat: 22.7201983, lng: 88.4703219 });
    const [mostFrequentPickup, setMostFrequentPickup] = useState(null);
    const [mostFrequentDrop, setMostFrequentDrop] = useState(null);

    useEffect(() => {
        const unsubscribe = onSnapshot(
            collection(db, 'Ride Details'),
            (snapshot) => {
                const ridesList = snapshot.docs.map((doc) => doc.data());
                setRides(ridesList);

                // Generate heatmap data from ride locations (pickup and drop)
                const heatmapPoints = ridesList.flatMap(ride => {
                    const pickupLat = ride['Pickup Latitude'];
                    const pickupLng = ride['Pick Longitude'];
                    const dropLat = ride['Drop Latitude'];
                    const dropLng = ride['Drop Longitude'];

                    if (
                        !pickupLat || !pickupLng || 
                        isNaN(pickupLat) || isNaN(pickupLng) || 
                        !dropLat || !dropLng || 
                        isNaN(dropLat) || isNaN(dropLng)
                    ) {
                        return [];
                    }

                    const pickup = { lat: pickupLat, lng: pickupLng };
                    const drop = { lat: dropLat, lng: dropLng };
                    
                    return [pickup, drop];
                });

                setHeatmapData(heatmapPoints);

                // Update map center based on the first ride's data
                if (heatmapPoints.length > 0) {
                    // console.log(heatmapPoints[0]);
                    setMapCenter(heatmapPoints[0]);
                }

                // Calculate most frequent pickup location
                const pickupCounts = ridesList.reduce((acc, ride) => {
                    const pickupLat = ride['Pickup Latitude'];
                    const pickupLng = ride['Pick Longitude'];
                    if (pickupLat && pickupLng && !isNaN(pickupLat) && !isNaN(pickupLng)) {
                        const key = `${pickupLat},${pickupLng}`;
                        acc[key] = (acc[key] || 0) + 1;
                    }
                    return acc;
                }, {});

                // Find the pickup point with the highest frequency
                let maxPickupCount = 0;
                let frequentPickup = null;
                for (const [key, count] of Object.entries(pickupCounts)) {
                    if (count > maxPickupCount) {
                        maxPickupCount = count;
                        frequentPickup = key;
                    }
                }

                if (frequentPickup) {
                    const [lat, lng] = frequentPickup.split(',').map(Number);
                    setMostFrequentPickup({ lat, lng });
                }

                // Calculate most frequent drop location
                const dropCounts = ridesList.reduce((acc, ride) => {
                    const dropLat = ride['Drop Latitude'];
                    const dropLng = ride['Drop Longitude'];
                    if (dropLat && dropLng && !isNaN(dropLat) && !isNaN(dropLng)) {
                        const key = `${dropLat},${dropLng}`;
                        acc[key] = (acc[key] || 0) + 1;
                    }
                    return acc;
                }, {});

                // Find the drop point with the highest frequency
                let maxDropCount = 0;
                let frequentDrop = null;
                for (const [key, count] of Object.entries(dropCounts)) {
                    if (count > maxDropCount) {
                        maxDropCount = count;
                        frequentDrop = key;
                    }
                }

                if (frequentDrop) {
                    const [lat, lng] = frequentDrop.split(',').map(Number);
                    setMostFrequentDrop({ lat, lng });
                }

                setLoading(false);
            },
            (error) => {
                console.error('Error fetching rides: ', error);
                setLoading(false);
            }
        );

        return () => unsubscribe();
    }, []);
    const mapOptions = {
        zoomControl: true,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
    };
    return (
        <div className="webbody" style={{ position: 'relative', width: '100%', height: '100vh', display: 'flex', flexDirection: 'column', overflowY: 'scroll', overflowX: 'hidden' }}>
            <div className="jnvjfnjf">
                <div className="jffbvfjv">
                    Heat View
                </div>
                <div className="divider"></div>
                <br />
                <LoadScript 
                    googleMapsApiKey="AIzaSyApzKC2nq9OCuaVQV2Jbm9cJoOHPy9kzvM"
                    libraries={["visualization"]}
                >
                    <GoogleMap
                        mapContainerStyle={{
                            width: '100%',
                            height: '100%',
                        }}
                        center={mapCenter}
                        zoom={12}
                        options={mapOptions}
                    >
                        {/* Heatmap Layer */}
                        {heatmapData.length > 0 && (
                            <HeatmapLayer
                                data={heatmapData}
                                options={{
                                    radius: 25,
                                    opacity: 0.7,
                                    gradient: [
                                        'rgba(0, 255, 255, 0)',
                                        'rgba(0, 255, 255, 1)',
                                        'rgba(0, 204, 255, 1)',
                                        'rgba(0, 153, 255, 1)',
                                        'rgba(0, 102, 255, 1)',
                                        'rgba(0, 51, 255, 1)',
                                        'rgba(0, 0, 255, 1)',
                                        'rgba(51, 0, 204, 1)',
                                        'rgba(102, 0, 255, 1)',
                                        'rgba(204, 0, 255, 1)',
                                        'rgba(255, 0, 255, 1)',
                                        'rgba(255, 0, 204, 1)',
                                        'rgba(255, 0, 102, 1)',
                                        'rgba(255, 0, 0, 1)',
                                    ],
                                }}
                            />
                        )}

                        {/* Red Circle on the most frequent pickup location */}
                        {mostFrequentPickup && (
                            <Circle
                                center={mostFrequentPickup}
                                radius={300} // Radius of 300 meters (adjust as needed)
                                options={{
                                    fillColor: 'red',
                                    fillOpacity: 0.35,
                                    strokeColor: 'red',
                                    strokeOpacity: 1,
                                    strokeWeight: 2,
                                }}
                            />
                        )}

                        {/* Orange Circle on the most frequent drop location */}
                        {mostFrequentDrop && (
                            <Circle
                                center={mostFrequentDrop}
                                radius={300} // Radius of 300 meters (adjust as needed)
                                options={{
                                    fillColor: 'orange',
                                    fillOpacity: 0.35,
                                    strokeColor: 'orange',
                                    strokeOpacity: 1,
                                    strokeWeight: 2,
                                }}
                            />
                        )}
                    </GoogleMap>
                </LoadScript>
            </div>
        </div>
    );
}

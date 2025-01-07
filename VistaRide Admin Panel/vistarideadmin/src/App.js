import logo from './logo.svg';
import './App.css';
import {
  BrowserRouter,
  Routes,
  Route
} from 'react-router-dom';
import Homepage from './HomePage/homepage';
import Trackactiveride from './Track Ride/trackactiveride';
import Loginpage from './Login or Signup/Loginpage';

function App() {
  return (
    <BrowserRouter>
      <Routes>
      <Route path="/" element={<Loginpage />} />
        <Route path="/home" element={<Homepage />} />
        <Route path="/track/:rideID" element={<Trackactiveride />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;

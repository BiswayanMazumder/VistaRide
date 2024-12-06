import logo from './logo.svg';
import './App.css';
import {
  BrowserRouter,
  Routes,
  Route
} from 'react-router-dom';
import LandingPage from './Opening Page/LandingPage';
import Cabbookingpage from './Opening Page/HomePage/cabbookingpage';
import Activeride from './Active Ride Page/activeride';
import Mytrips from './My Trips/mytrips';
import Tripdetails from './My Trips/tripdetails';
function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
      </Routes>
      <Routes>
        <Route path="/go/home" element={<Cabbookingpage />} />
      </Routes>
      <Routes>
        <Route path="/trips" element={<Mytrips />} />
      </Routes>
      <Routes>
        <Route path="/ride/:RideID" element={<Activeride />} />
      </Routes>
      <Routes>
        <Route path="/trips/:tripid" element={<Tripdetails />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;

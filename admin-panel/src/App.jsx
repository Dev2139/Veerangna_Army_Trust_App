import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import Campaigns from './pages/Campaigns';
import NewsManagement from './pages/NewsManagement';
import EventsManagement from './pages/EventsManagement';
import GalleryManagement from './pages/GalleryManagement';
import FoodGalleryManagement from './pages/FoodGalleryManagement';
import BannersManagement from './pages/BannersManagement';
import DonationsManagement from './pages/DonationsManagement';

function App() {
  return (
    <Router>
      <div className="flex h-screen bg-gray-50">
        <Sidebar />
        <div className="flex-1 flex flex-col overflow-hidden">
          <header className="bg-white shadow-sm h-16 flex items-center justify-between px-6">
            <h1 className="text-xl font-semibold text-gray-800">Admin Panel</h1>
            <div className="flex items-center gap-4">
              <span className="text-sm font-medium text-gray-600">Admin User</span>
              <div className="w-8 h-8 rounded-full bg-armyGreen text-white flex items-center justify-center font-bold">A</div>
            </div>
          </header>
          <main className="flex-1 overflow-x-hidden overflow-y-auto bg-gray-100 p-6">
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/campaigns" element={<Campaigns />} />
              <Route path="/news" element={<NewsManagement />} />
              <Route path="/events" element={<EventsManagement />} />
              <Route path="/gallery" element={<GalleryManagement />} />
              <Route path="/food-gallery" element={<FoodGalleryManagement />} />
              <Route path="/banners" element={<BannersManagement />} />
              <Route path="/donations" element={<DonationsManagement />} />
              <Route path="/users" element={<div className="text-2xl font-bold">Users Management (WIP)</div>} />
            </Routes>
          </main>
        </div>
      </div>
    </Router>
  );
}

export default App;

import { Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, Megaphone, IndianRupee, Users, Settings, Newspaper, Calendar, Image as ImageIcon, MonitorPlay } from 'lucide-react';

const Sidebar = () => {
  const location = useLocation();
  
  const navItems = [
    { name: 'Dashboard', path: '/', icon: <LayoutDashboard size={20} /> },
    { name: 'Campaigns', path: '/campaigns', icon: <Megaphone size={20} /> },
    { name: 'News & Updates', path: '/news', icon: <Newspaper size={20} /> },
    { name: 'Events', path: '/events', icon: <Calendar size={20} /> },
    { name: 'Gallery', path: '/gallery', icon: <ImageIcon size={20} /> },
    { name: 'Food Gallery', path: '/food-gallery', icon: <ImageIcon size={20} /> },
    { name: 'Banners', path: '/banners', icon: <MonitorPlay size={20} /> },
    { name: 'Donations', path: '/donations', icon: <IndianRupee size={20} /> },
    { name: 'Users', path: '/users', icon: <Users size={20} /> },
  ];

  return (
    <div className="w-64 bg-armyGreen text-white flex flex-col">
      <div className="h-16 flex items-center gap-3 px-6 border-b border-white/10">
        <img src="https://res.cloudinary.com/dsddldquo/image/upload/v1781593109/tsrwudiwazhmwm78oa4g.jpg" alt="Logo" className="w-8 h-8 rounded-full object-cover" />
        <h2 className="text-xl font-bold text-saffron">Army Trust</h2>
      </div>
      <nav className="flex-1 px-4 py-6 space-y-2">
        {navItems.map((item) => {
          const isActive = location.pathname === item.path;
          return (
            <Link
              key={item.name}
              to={item.path}
              className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${isActive ? 'bg-white/20 font-medium' : 'hover:bg-white/10 text-gray-200'}`}
            >
              {item.icon}
              {item.name}
            </Link>
          );
        })}
      </nav>
      <div className="p-4 border-t border-white/10">
        <button className="flex items-center gap-3 px-4 py-2 w-full text-left text-gray-300 hover:text-white transition-colors">
          <Settings size={20} />
          Settings
        </button>
      </div>
    </div>
  );
};

export default Sidebar;

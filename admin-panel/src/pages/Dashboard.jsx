import { useState, useEffect } from 'react';
import { IndianRupee, Users, TrendingUp, Heart } from 'lucide-react';
import { getDashboardStats } from '../services/api';

const Dashboard = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const statsData = await getDashboardStats();
        setData(statsData);
      } catch (err) {
        setError('Failed to load dashboard statistics.');
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) return <div className="p-8 text-center text-gray-500">Loading dashboard data...</div>;
  if (error) return <div className="p-8 text-center text-red-500">{error}</div>;

  const stats = [
    { title: 'Total Donations', value: `₹ ${data.stats.totalDonations.toLocaleString()}`, icon: <IndianRupee size={24} className="text-armyGreen" /> },
    { title: 'Active Campaigns', value: data.stats.activeCampaigns.toString(), icon: <TrendingUp size={24} className="text-saffron" /> },
    { title: 'Total Beneficiaries', value: data.stats.totalBeneficiaries.toString(), icon: <Heart size={24} className="text-red-500" /> },
    { title: 'Registered Users', value: data.stats.totalUsers.toString(), icon: <Users size={24} className="text-blue-500" /> },
  ];

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-800">Dashboard Overview</h2>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat) => (
          <div key={stat.title} className="bg-white p-6 rounded-xl shadow-sm flex items-center justify-between border border-gray-100">
            <div>
              <p className="text-sm font-medium text-gray-500">{stat.title}</p>
              <h3 className="text-2xl font-bold text-gray-900 mt-1">{stat.value}</h3>
            </div>
            <div className="w-12 h-12 bg-gray-50 rounded-full flex items-center justify-center">
              {stat.icon}
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-8">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <h3 className="text-lg font-bold text-gray-800 mb-4">Recent Donations</h3>
          <div className="space-y-4">
            {data.recentDonations.length === 0 ? (
              <p className="text-gray-500 text-sm">No donations yet.</p>
            ) : (
              data.recentDonations.map((donation, i) => (
                <div key={donation._id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-full bg-armyGreen/10 flex items-center justify-center text-armyGreen font-bold">
                      {donation.user?.name?.charAt(0).toUpperCase() || 'U'}
                    </div>
                    <div>
                      <p className="font-medium text-gray-900">{donation.user?.name || 'Anonymous User'}</p>
                      <p className="text-sm text-gray-500">{donation.campaign?.title || 'General Donation'}</p>
                    </div>
                  </div>
                  <span className="font-bold text-armyGreen">+ ₹{donation.amount.toLocaleString()}</span>
                </div>
              ))
            )}
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <h3 className="text-lg font-bold text-gray-800 mb-4">Campaign Progress</h3>
          <div className="space-y-6">
            {data.campaignsProgress.length === 0 ? (
              <p className="text-gray-500 text-sm">No active campaigns.</p>
            ) : (
              data.campaignsProgress.map((campaign) => {
                const progress = campaign.amountRequired > 0 
                  ? Math.min((campaign.amountCollected / campaign.amountRequired) * 100, 100) 
                  : 0;
                
                return (
                  <div key={campaign._id}>
                    <div className="flex justify-between mb-2">
                      <span className="font-medium text-gray-800">{campaign.title}</span>
                      <span className="text-sm text-gray-500">{progress.toFixed(1)}%</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div className="bg-saffron h-2 rounded-full" style={{ width: `${progress}%` }}></div>
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;

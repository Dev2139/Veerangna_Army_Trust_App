import React, { useState, useEffect } from 'react';
import { Users, Search, Trash2, Eye, ShieldCheck, Mail, Phone, IndianRupee, HeartHandshake } from 'lucide-react';
import api from '../services/api';

const UsersManagement = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [deletingId, setDeletingId] = useState(null);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const response = await api.get('/admin/users');
      setUsers(response.data);
    } catch (error) {
      console.error('Failed to fetch users', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteUser = async (id) => {
    if (!window.confirm('Are you sure you want to delete this user?')) return;
    try {
      setDeletingId(id);
      await api.delete(`/admin/users/${id}`);
      setUsers(users.filter(u => u._id !== id));
      if (selectedUser?._id === id) setSelectedUser(null);
    } catch (error) {
      console.error('Failed to delete user', error);
      alert('Failed to delete user');
    } finally {
      setDeletingId(null);
    }
  };

  const filteredUsers = users
    .filter(user => {
      const term = searchTerm.toLowerCase();
      return (
        (user.name && user.name.toLowerCase().includes(term)) ||
        (user.email && user.email.toLowerCase().includes(term)) ||
        (user.phone && user.phone.includes(term)) ||
        (user.billingInfo?.panCard && user.billingInfo.panCard.toLowerCase().includes(term))
      );
    })
    .sort((a, b) => (b.totalDonated || 0) - (a.totalDonated || 0) || (b.donationCount || 0) - (a.donationCount || 0));

  const totalUsers = users.length;
  const activeDonors = users.filter(u => u.donationCount > 0).length;
  const totalDonatedVolume = users.reduce((sum, u) => sum + (u.totalDonated || 0), 0);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-800">Users Management</h1>
          <p className="text-gray-500 text-sm mt-1">Manage registered donors, user profiles, and activity logs (Sorted by Total Donated)</p>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
          <div className="w-12 h-12 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
            <Users size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">Total Registered Users</p>
            <h3 className="text-2xl font-bold text-gray-800 mt-1">{totalUsers}</h3>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
          <div className="w-12 h-12 rounded-lg bg-purple-50 text-purple-600 flex items-center justify-center">
            <HeartHandshake size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">Active Donors</p>
            <h3 className="text-2xl font-bold text-gray-800 mt-1">{activeDonors}</h3>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
          <div className="w-12 h-12 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
            <IndianRupee size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">Total User Contributions</p>
            <h3 className="text-2xl font-bold text-emerald-600 mt-1">₹{totalDonatedVolume.toLocaleString()}</h3>
          </div>
        </div>
      </div>

      {/* Search & Filter Bar */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-4 bg-gray-50 border-b flex flex-col sm:flex-row justify-between items-center gap-4">
          <div className="relative w-full sm:w-80">
            <Search className="absolute left-3 top-2.5 text-gray-400" size={18} />
            <input
              type="text"
              placeholder="Search by name, email, phone, PAN..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <span className="text-xs text-gray-500 font-medium">
            Showing {filteredUsers.length} of {users.length} users (Sorted by highest contribution)
          </span>
        </div>

        {/* Table */}
        {loading ? (
          <div className="p-8 space-y-4">
            {[1, 2, 3, 4].map(i => (
              <div key={i} className="animate-pulse flex space-x-4">
                <div className="h-10 bg-gray-200 rounded w-full"></div>
              </div>
            ))}
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead className="bg-gray-50 border-b text-xs font-semibold text-gray-500 uppercase tracking-wider">
                <tr>
                  <th className="px-4 py-3 text-center">Rank</th>
                  <th className="px-6 py-3">User Details</th>
                  <th className="px-6 py-3">Contact</th>
                  <th className="px-6 py-3">Role</th>
                  <th className="px-6 py-3 text-emerald-700">Donations (Highest First ↓)</th>
                  <th className="px-6 py-3">Joined Date</th>
                  <th className="px-6 py-3 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 text-sm">
                {filteredUsers.length === 0 ? (
                  <tr>
                    <td colSpan="7" className="px-6 py-12 text-center text-gray-500">
                      No users found.
                    </td>
                  </tr>
                ) : (
                  filteredUsers.map((u, index) => (
                    <tr key={u._id} className="hover:bg-gray-50 transition-colors">
                      <td className="px-4 py-4 whitespace-nowrap text-center">
                        {index === 0 && u.totalDonated > 0 ? (
                          <span className="inline-flex items-center justify-center w-7 h-7 rounded-full bg-amber-100 text-amber-700 font-bold text-xs border border-amber-300" title="Top Donor (#1)">
                            🥇
                          </span>
                        ) : index === 1 && u.totalDonated > 0 ? (
                          <span className="inline-flex items-center justify-center w-7 h-7 rounded-full bg-slate-200 text-slate-700 font-bold text-xs border border-slate-300" title="2nd Highest Donor">
                            🥈
                          </span>
                        ) : index === 2 && u.totalDonated > 0 ? (
                          <span className="inline-flex items-center justify-center w-7 h-7 rounded-full bg-amber-700/10 text-amber-900 font-bold text-xs border border-amber-600/30" title="3rd Highest Donor">
                            🥉
                          </span>
                        ) : (
                          <span className="text-xs font-semibold text-gray-400">#{index + 1}</span>
                        )}
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center gap-3">
                          <div className="w-9 h-9 rounded-full bg-blue-100 text-blue-600 font-bold flex items-center justify-center text-sm uppercase">
                            {u.name ? u.name.charAt(0) : 'U'}
                          </div>
                          <div>
                            <div className="font-semibold text-gray-900">{u.name || 'Unnamed User'}</div>
                            {u.billingInfo?.panCard && (
                              <div className="text-xs text-gray-400 font-mono">PAN: {u.billingInfo.panCard}</div>
                            )}
                          </div>
                        </div>
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-gray-900 font-medium flex items-center gap-1.5">
                          <Mail size={14} className="text-gray-400" />
                          <span>{u.email}</span>
                        </div>
                        {u.phone && (
                          <div className="text-xs text-gray-500 flex items-center gap-1.5 mt-0.5">
                            <Phone size={12} className="text-gray-400" />
                            <span>{u.phone}</span>
                          </div>
                        )}
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                          u.role === 'admin' 
                            ? 'bg-purple-100 text-purple-800' 
                            : 'bg-blue-100 text-blue-800'
                        }`}>
                          {u.role === 'admin' && <ShieldCheck size={12} className="mr-1" />}
                          {u.role ? u.role.toUpperCase() : 'USER'}
                        </span>
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="font-semibold text-emerald-600">₹{(u.totalDonated || 0).toLocaleString()}</div>
                        <div className="text-xs text-gray-500">{u.donationCount || 0} donations</div>
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap text-gray-500 text-xs">
                        {u.createdAt ? new Date(u.createdAt).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric'
                        }) : 'N/A'}
                      </td>

                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm">
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => setSelectedUser(u)}
                            className="p-1.5 text-gray-600 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                            title="View Details"
                          >
                            <Eye size={18} />
                          </button>
                          <button
                            onClick={() => handleDeleteUser(u._id)}
                            disabled={deletingId === u._id}
                            className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
                            title="Delete User"
                          >
                            <Trash2 size={18} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* User Details Modal */}
      {selectedUser && (
        <div className="fixed inset-0 bg-black bg-opacity-40 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl relative max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-start border-b pb-4">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-blue-600 text-white font-bold text-lg flex items-center justify-center">
                  {selectedUser.name ? selectedUser.name.charAt(0).toUpperCase() : 'U'}
                </div>
                <div>
                  <h2 className="text-xl font-bold text-gray-900">{selectedUser.name}</h2>
                  <p className="text-xs text-gray-500">ID: {selectedUser._id}</p>
                </div>
              </div>
              <button
                onClick={() => setSelectedUser(null)}
                className="text-gray-400 hover:text-gray-600 font-bold text-xl leading-none"
              >
                &times;
              </button>
            </div>

            <div className="mt-4 space-y-4">
              <div>
                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Account Information</h4>
                <div className="bg-gray-50 p-3 rounded-lg space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-gray-500">Email:</span>
                    <span className="font-medium text-gray-800">{selectedUser.email}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500">Phone:</span>
                    <span className="font-medium text-gray-800">{selectedUser.phone || 'Not provided'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500">Role:</span>
                    <span className="font-semibold text-blue-600 uppercase">{selectedUser.role || 'user'}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-gray-500">Joined Date:</span>
                    <span className="font-medium text-gray-800">
                      {selectedUser.createdAt ? new Date(selectedUser.createdAt).toLocaleString() : 'N/A'}
                    </span>
                  </div>
                </div>
              </div>

              <div>
                <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Contribution Summary</h4>
                <div className="bg-emerald-50 border border-emerald-100 p-3 rounded-lg flex justify-between items-center text-sm">
                  <div>
                    <p className="text-xs text-emerald-700 font-medium">Total Donated</p>
                    <p className="text-lg font-bold text-emerald-800">₹{(selectedUser.totalDonated || 0).toLocaleString()}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-xs text-emerald-700 font-medium">Total Transactions</p>
                    <p className="text-lg font-bold text-emerald-800">{selectedUser.donationCount || 0}</p>
                  </div>
                </div>
              </div>

              {selectedUser.billingInfo && (
                <div>
                  <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Billing & Tax Details</h4>
                  <div className="bg-gray-50 p-3 rounded-lg space-y-2 text-sm">
                    {selectedUser.billingInfo.panCard && (
                      <div className="flex justify-between">
                        <span className="text-gray-500">PAN Card:</span>
                        <span className="font-mono font-bold text-gray-800">{selectedUser.billingInfo.panCard}</span>
                      </div>
                    )}
                    <div className="flex justify-between">
                      <span className="text-gray-500">City / State:</span>
                      <span className="font-medium text-gray-800">
                        {[selectedUser.billingInfo.city, selectedUser.billingInfo.state].filter(Boolean).join(', ') || 'Not provided'}
                      </span>
                    </div>
                  </div>
                </div>
              )}
            </div>

            <div className="mt-6 border-t pt-4 flex justify-end">
              <button
                onClick={() => setSelectedUser(null)}
                className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 text-sm font-medium transition-colors"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default UsersManagement;

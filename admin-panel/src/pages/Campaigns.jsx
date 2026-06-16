import { useState, useEffect } from 'react';
import { Plus, X, Image as ImageIcon, Trash2 } from 'lucide-react';
import { getCampaigns, createCampaign, deleteCampaign } from '../services/api';

const Campaigns = () => {
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    amountRequired: '',
    imageFile: null
  });

  const fetchCampaigns = async () => {
    try {
      const data = await getCampaigns();
      setCampaigns(data);
    } catch (error) {
      console.error("Failed to fetch campaigns", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCampaigns();
  }, []);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleDelete = async (id) => {
    if (window.confirm("Are you sure you want to delete this campaign?")) {
      try {
        await deleteCampaign(id);
        fetchCampaigns();
      } catch (error) {
        console.error("Failed to delete campaign", error);
      }
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      const payload = new FormData();
      payload.append('title', formData.title);
      payload.append('description', formData.description);
      payload.append('amountRequired', formData.amountRequired);
      if (formData.imageFile) {
        payload.append('image', formData.imageFile);
      }
      
      await createCampaign(payload);
      setIsModalOpen(false);
      setFormData({ title: '', description: '', amountRequired: '', imageFile: null });
      fetchCampaigns(); // Refresh the list
    } catch (error) {
      console.error("Failed to create campaign", error);
      alert("Error creating campaign");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6 relative">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-800">Campaigns Management</h2>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 bg-saffron text-white px-4 py-2 rounded-lg font-medium hover:bg-orange-500 transition-colors"
        >
          <Plus size={20} />
          Create Campaign
        </button>
      </div>

      {loading ? (
        <div className="p-8 text-center text-gray-500">Loading campaigns...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {campaigns.map((campaign) => (
            <div key={campaign._id} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden flex flex-col">
              <div className="h-48 bg-gray-200 relative">
                {campaign.images && campaign.images.length > 0 ? (
                  <img src={campaign.images[0]} alt={campaign.title} className="w-full h-full object-cover" />
                ) : (
                  <div className="flex items-center justify-center h-full text-gray-400">
                    <ImageIcon size={48} />
                  </div>
                )}
                <div className={`absolute top-4 right-4 px-3 py-1 rounded-full text-xs font-bold \${campaign.status === 'active' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700'}`}>
                  {campaign.status.toUpperCase()}
                </div>
              </div>
              <div className="p-5 flex-1 flex flex-col">
                <div className="flex justify-between items-start gap-2">
                  <h3 className="text-xl font-bold text-gray-900 line-clamp-1 flex-1">{campaign.title}</h3>
                  <button onClick={() => handleDelete(campaign._id)} className="p-1.5 bg-red-50 hover:bg-red-100 text-red-600 rounded-lg transition flex-shrink-0" title="Delete Campaign">
                    <Trash2 size={16} />
                  </button>
                </div>
                <p className="text-sm text-gray-500 mt-2 line-clamp-2 flex-1">{campaign.description}</p>
                
                <div className="mt-4 pt-4 border-t border-gray-100">
                  <div className="flex justify-between text-sm mb-2">
                    <span className="font-medium text-gray-800">₹ {campaign.amountCollected.toLocaleString()}</span>
                    <span className="text-gray-500">of ₹ {campaign.amountRequired.toLocaleString()}</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-armyGreen h-2 rounded-full" 
                      style={{ width: `\${Math.min((campaign.amountCollected / campaign.amountRequired) * 100, 100)}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create Campaign Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-xl overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50">
              <h3 className="text-xl font-bold text-gray-800">Create New Campaign</h3>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Campaign Title</label>
                <input 
                  type="text" 
                  name="title"
                  required
                  value={formData.title}
                  onChange={handleChange}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen focus:border-transparent outline-none"
                  placeholder="e.g. Martyr Family Support Fund"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea 
                  name="description"
                  required
                  rows={4}
                  value={formData.description}
                  onChange={handleChange}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen focus:border-transparent outline-none"
                  placeholder="Describe the cause and how the funds will be used..."
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Goal Amount (₹)</label>
                  <input 
                    type="number" 
                    name="amountRequired"
                    required
                    min="100"
                    value={formData.amountRequired}
                    onChange={handleChange}
                    className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen focus:border-transparent outline-none"
                    placeholder="e.g. 500000"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Campaign Banner Image</label>
                  <input 
                    type="file" 
                    name="imageFile"
                    accept="image/*"
                    onChange={(e) => setFormData({ ...formData, imageFile: e.target.files[0] })}
                    className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen focus:border-transparent outline-none"
                  />
                </div>
              </div>

              <div className="pt-4 flex items-center justify-end gap-3">
                <button 
                  type="button" 
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 text-gray-600 font-medium hover:bg-gray-100 rounded-lg transition-colors"
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  disabled={isSubmitting}
                  className="px-6 py-2 bg-armyGreen text-white font-medium rounded-lg hover:bg-[#3A4119] transition-colors disabled:opacity-50"
                >
                  {isSubmitting ? 'Creating...' : 'Launch Campaign'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Campaigns;

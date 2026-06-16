import { useState, useEffect } from 'react';
import { Upload, X, Trash2, Power } from 'lucide-react';
import { getBanners, createBanner, updateBannerStatus, deleteBanner } from '../services/api';

const BannersManagement = () => {
  const [banners, setBanners] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    targetUrl: '',
    isActive: true,
    imageFile: null
  });

  const fetchBanners = async () => {
    try {
      const data = await getBanners();
      setBanners(data);
    } catch (error) {
      console.error("Failed to fetch banners", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBanners();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.imageFile) {
      alert("Please select an image to upload");
      return;
    }
    
    setIsSubmitting(true);
    try {
      const payload = new FormData();
      payload.append('title', formData.title);
      payload.append('targetUrl', formData.targetUrl);
      payload.append('isActive', formData.isActive);
      payload.append('image', formData.imageFile);
      
      await createBanner(payload);
      setIsModalOpen(false);
      setFormData({ title: '', targetUrl: '', isActive: true, imageFile: null });
      fetchBanners(); 
    } catch (error) {
      console.error("Failed to upload banner", error);
      alert("Error uploading banner");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleToggleStatus = async (id, currentStatus) => {
    try {
      await updateBannerStatus(id, !currentStatus);
      fetchBanners();
    } catch (error) {
      console.error("Failed to update status", error);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm("Are you sure you want to delete this banner?")) {
      try {
        await deleteBanner(id);
        fetchBanners();
      } catch (error) {
        console.error("Failed to delete banner", error);
      }
    }
  };

  return (
    <div className="space-y-6 relative">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-800">Banners Management</h2>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 bg-armyGreen text-white px-4 py-2 rounded-lg font-medium hover:bg-[#3A4119] transition-colors"
        >
          <Upload size={20} />
          Upload Banner
        </button>
      </div>

      {loading ? (
        <div className="p-8 text-center text-gray-500">Loading banners...</div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {banners.map((banner) => (
            <div key={banner._id} className={`bg-white rounded-xl shadow-sm border overflow-hidden relative group \${!banner.isActive ? 'opacity-70 border-gray-300' : 'border-gray-100'}`}>
              <div className="h-40 w-full overflow-hidden">
                <img src={banner.imageUrl} alt={banner.title || 'Banner image'} className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105" />
              </div>
              <div className="p-4">
                <h3 className="font-bold text-lg mb-1">{banner.title || 'Untitled Banner'}</h3>
                {banner.targetUrl && (
                  <p className="text-sm text-blue-600 truncate mb-3"><a href={banner.targetUrl} target="_blank" rel="noreferrer">{banner.targetUrl}</a></p>
                )}
                <div className="flex items-center justify-between mt-4">
                  <span className={`px-2 py-1 text-xs font-semibold rounded-full \${banner.isActive ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'}`}>
                    {banner.isActive ? 'Active' : 'Inactive'}
                  </span>
                  <div className="flex gap-2">
                    <button onClick={() => handleToggleStatus(banner._id, banner.isActive)} className="p-2 bg-gray-100 hover:bg-gray-200 text-gray-600 rounded-lg transition" title="Toggle Status">
                      <Power size={16} />
                    </button>
                    <button onClick={() => handleDelete(banner._id)} className="p-2 bg-red-50 hover:bg-red-100 text-red-600 rounded-lg transition" title="Delete">
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-md overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50">
              <h3 className="text-xl font-bold text-gray-800">Upload New Banner</h3>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Select Photo (Recommended aspect ratio 16:9)</label>
                <input 
                  type="file" 
                  required
                  accept="image/*"
                  onChange={(e) => setFormData({ ...formData, imageFile: e.target.files[0] })}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen outline-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Title (Optional)</label>
                <input 
                  type="text" 
                  name="title"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen outline-none"
                  placeholder="e.g. Independence Day Campaign"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Target Link URL (Optional)</label>
                <input 
                  type="url" 
                  name="targetUrl"
                  value={formData.targetUrl}
                  onChange={(e) => setFormData({ ...formData, targetUrl: e.target.value })}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen outline-none"
                  placeholder="https://example.com"
                />
              </div>

              <div className="flex items-center gap-2 mt-2">
                <input 
                  type="checkbox" 
                  id="isActive"
                  checked={formData.isActive}
                  onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                  className="rounded text-armyGreen focus:ring-armyGreen"
                />
                <label htmlFor="isActive" className="text-sm font-medium text-gray-700">Set as Active immediately</label>
              </div>

              <div className="pt-4 flex justify-end gap-3">
                <button type="button" onClick={() => setIsModalOpen(false)} className="px-4 py-2 text-gray-600 font-medium hover:bg-gray-100 rounded-lg">Cancel</button>
                <button type="submit" disabled={isSubmitting} className="px-6 py-2 bg-armyGreen text-white font-medium rounded-lg hover:bg-[#3A4119] disabled:opacity-50 flex items-center gap-2">
                  {isSubmitting ? 'Uploading...' : <><Upload size={18} /> Upload</>}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default BannersManagement;

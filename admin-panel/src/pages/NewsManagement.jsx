import { useState, useEffect } from 'react';
import { Plus, X, Image as ImageIcon } from 'lucide-react';
import { getNews, createNews } from '../services/api';

const NewsManagement = () => {
  const [news, setNews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    title: '',
    content: '',
    type: 'news',
    imageFile: null
  });

  const fetchNews = async () => {
    try {
      const data = await getNews();
      setNews(data);
    } catch (error) {
      console.error("Failed to fetch news", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchNews();
  }, []);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      const payload = new FormData();
      payload.append('title', formData.title);
      payload.append('content', formData.content);
      payload.append('type', formData.type);
      if (formData.imageFile) {
        payload.append('image', formData.imageFile);
      }
      
      await createNews(payload);
      setIsModalOpen(false);
      setFormData({ title: '', content: '', type: 'news', imageFile: null });
      fetchNews(); 
    } catch (error) {
      console.error("Failed to create news", error);
      alert("Error creating news");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6 relative">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-800">News & Updates</h2>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 bg-armyGreen text-white px-4 py-2 rounded-lg font-medium hover:bg-[#3A4119] transition-colors"
        >
          <Plus size={20} />
          Create News
        </button>
      </div>

      {loading ? (
        <div className="p-8 text-center text-gray-500">Loading news...</div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {news.map((item) => (
            <div key={item._id} className="bg-white rounded-xl shadow-sm border border-gray-100 flex overflow-hidden h-40">
              <div className="w-40 bg-gray-200 shrink-0">
                {item.mediaUrl ? (
                  <img src={item.mediaUrl} alt={item.title} className="w-full h-full object-cover" />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-gray-400">
                    <ImageIcon size={32} />
                  </div>
                )}
              </div>
              <div className="p-4 flex-1 flex flex-col justify-center">
                <div className="flex items-center justify-between mb-1">
                  <span className={`text-xs font-bold px-2 py-1 rounded \${item.type === 'motivational' ? 'bg-saffron/20 text-orange-700' : 'bg-gray-100 text-gray-600'}`}>
                    {item.type.toUpperCase()}
                  </span>
                  <span className="text-xs text-gray-400">{new Date(item.createdAt).toLocaleDateString()}</span>
                </div>
                <h3 className="font-bold text-gray-900 line-clamp-1">{item.title}</h3>
                <p className="text-sm text-gray-500 mt-1 line-clamp-2">{item.content}</p>
                <div className="mt-2 text-xs font-medium text-armyGreen">{item.likesCount} Likes</div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-xl overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50">
              <h3 className="text-xl font-bold text-gray-800">Publish News</h3>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                <input 
                  type="text" 
                  name="title"
                  required
                  value={formData.title}
                  onChange={handleChange}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen outline-none"
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Content</label>
                <textarea 
                  name="content"
                  required
                  rows={4}
                  value={formData.content}
                  onChange={handleChange}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
                  <select
                    name="type"
                    value={formData.type}
                    onChange={handleChange}
                    className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen outline-none"
                  >
                    <option value="news">News</option>
                    <option value="motivational">Motivational</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Cover Image</label>
                  <input 
                    type="file" 
                    accept="image/*"
                    onChange={(e) => setFormData({ ...formData, imageFile: e.target.files[0] })}
                    className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen outline-none"
                  />
                </div>
              </div>

              <div className="pt-4 flex justify-end gap-3">
                <button type="button" onClick={() => setIsModalOpen(false)} className="px-4 py-2 text-gray-600 font-medium hover:bg-gray-100 rounded-lg">Cancel</button>
                <button type="submit" disabled={isSubmitting} className="px-6 py-2 bg-armyGreen text-white font-medium rounded-lg hover:bg-[#3A4119] disabled:opacity-50">
                  {isSubmitting ? 'Publishing...' : 'Publish'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default NewsManagement;

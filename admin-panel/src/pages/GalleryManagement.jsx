import { useState, useEffect } from 'react';
import { Upload, X, Image as ImageIcon } from 'lucide-react';
import { getGallery, createGalleryImage } from '../services/api';

const GalleryManagement = () => {
  const [images, setImages] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [formData, setFormData] = useState({
    caption: '',
    imageFile: null
  });

  const fetchImages = async () => {
    try {
      const data = await getGallery();
      setImages(data);
    } catch (error) {
      console.error("Failed to fetch gallery", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchImages();
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
      payload.append('caption', formData.caption);
      payload.append('image', formData.imageFile);
      
      await createGalleryImage(payload);
      setIsModalOpen(false);
      setFormData({ caption: '', imageFile: null });
      fetchImages(); 
    } catch (error) {
      console.error("Failed to upload image", error);
      alert("Error uploading image");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-6 relative">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-800">Media Gallery</h2>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 bg-armyGreen text-white px-4 py-2 rounded-lg font-medium hover:bg-[#3A4119] transition-colors"
        >
          <Upload size={20} />
          Upload Photo
        </button>
      </div>

      {loading ? (
        <div className="p-8 text-center text-gray-500">Loading gallery...</div>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {images.map((img) => (
            <div key={img._id} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden relative group aspect-square">
              <img src={img.imageUrl} alt={img.caption || 'Gallery image'} className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105" />
              {img.caption && (
                <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/80 to-transparent p-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <p className="text-white text-sm font-medium line-clamp-2">{img.caption}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-md overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50">
              <h3 className="text-xl font-bold text-gray-800">Upload to Gallery</h3>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X size={24} />
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Select Photo</label>
                <input 
                  type="file" 
                  required
                  accept="image/*"
                  onChange={(e) => setFormData({ ...formData, imageFile: e.target.files[0] })}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen outline-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Caption (Optional)</label>
                <input 
                  type="text" 
                  name="caption"
                  value={formData.caption}
                  onChange={(e) => setFormData({ ...formData, caption: e.target.value })}
                  className="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-2 focus:ring-armyGreen outline-none"
                  placeholder="e.g. Independence Day Celebration"
                />
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

export default GalleryManagement;

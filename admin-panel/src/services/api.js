import axios from 'axios';

const api = axios.create({
  baseURL: 'https://veerangna-army-trust-app.vercel.app/api',
});

// Interceptor to add token if exists
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const getDashboardStats = async () => {
  const response = await api.get('/admin/stats');
  return response.data;
};

export const getCampaigns = async () => {
  const response = await api.get('/campaigns');
  return response.data;
};

export const createCampaign = async (campaignData) => {
  const response = await api.post('/campaigns', campaignData);
  return response.data;
};

export const deleteCampaign = async (id) => {
  const response = await api.delete(`/campaigns/${id}`);
  return response.data;
};

// --- News ---
export const getNews = async () => {
  const response = await api.get('/news');
  return response.data;
};

export const createNews = async (newsData) => {
  const response = await api.post('/news', newsData);
  return response.data;
};

// --- Events ---
export const getEvents = async () => {
  const response = await api.get('/events');
  return response.data;
};

export const createEvent = async (eventData) => {
  const response = await api.post('/events', eventData);
  return response.data;
};

// --- Gallery ---
export const getGallery = async () => {
  const response = await api.get('/gallery');
  return response.data;
};

export const createGalleryImage = async (galleryData) => {
  const response = await api.post('/gallery', galleryData);
  return response.data;
};

// --- Food Gallery ---
export const getFoodGallery = async () => {
  const response = await api.get('/food-gallery');
  return response.data;
};

export const createFoodGalleryImage = async (galleryData) => {
  const response = await api.post('/food-gallery', galleryData);
  return response.data;
};

// --- Banners ---
export const getBanners = async () => {
  const response = await api.get('/banners');
  return response.data;
};

export const createBanner = async (bannerData) => {
  const response = await api.post('/banners', bannerData);
  return response.data;
};

export const updateBannerStatus = async (id, isActive) => {
  const response = await api.patch(`/banners/${id}`, { isActive });
  return response.data;
};

export const deleteBanner = async (id) => {
  const response = await api.delete(`/banners/${id}`);
  return response.data;
};

export default api;

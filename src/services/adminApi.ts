import axios, { AxiosInstance, AxiosResponse } from 'axios';

// Create axios instance
const api: AxiosInstance = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('admin_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response: AxiosResponse) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('admin_token');
      window.location.href = '/admin/login';
    }
    return Promise.reject(error);
  }
);

// API endpoints
export const adminApi = {
  // Authentication
  login: (credentials: { email: string; password: string }) =>
    api.post('/admin/auth/login', credentials),
  
  logout: () => api.post('/admin/auth/logout'),
  
  getProfile: () => api.get('/admin/profile'),
  
  // Notifications
  getNotifications: () => api.get('/admin/notifications'),
  
  markNotificationAsRead: (id: string) =>
    api.put(`/admin/notifications/${id}/read`),
  
  // Users
  getUsers: (params: any) => api.get('/admin/users', { params }),
  
  getUser: (id: string) => api.get(`/admin/users/${id}`),
  
  updateUser: (id: string, data: any) => api.put(`/admin/users/${id}`, data),
  
  deleteUser: (id: string) => api.delete(`/admin/users/${id}`),
  
  // Content
  getContent: (params: any) => api.get('/admin/content', { params }),
  
  getContentItem: (id: string) => api.get(`/admin/content/${id}`),
  
  updateContent: (id: string, data: any) => api.put(`/admin/content/${id}`, data),
  
  deleteContent: (id: string) => api.delete(`/admin/content/${id}`),
  
  // Analytics
  getDashboardStats: () => api.get('/admin/analytics/dashboard'),
  
  getSystemMetrics: () => api.get('/admin/analytics/system'),
  
  getUserAnalytics: (params: any) => api.get('/admin/analytics/users', { params }),
  
  getContentAnalytics: (params: any) => api.get('/admin/analytics/content', { params }),
  
  // Settings
  getSettings: () => api.get('/admin/settings'),
  
  updateSettings: (data: any) => api.put('/admin/settings', data),
  
  // System
  getSystemHealth: () => api.get('/admin/system/health'),
  
  getSystemLogs: (params: any) => api.get('/admin/system/logs', { params }),
};

export default api;

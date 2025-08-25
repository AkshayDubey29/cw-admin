import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { adminApi } from '@/services/adminApi';

export interface AdminUser {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'super_admin' | 'moderator';
  permissions: string[];
  lastLogin: string;
  isActive: boolean;
}

export interface AdminState {
  user: AdminUser | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  notifications: Notification[];
  sidebarCollapsed: boolean;
}

export interface Notification {
  id: string;
  type: 'info' | 'success' | 'warning' | 'error';
  message: string;
  timestamp: string;
  read: boolean;
}

const initialState: AdminState = {
  user: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,
  notifications: [],
  sidebarCollapsed: false,
};

// Async thunks
export const loginAdmin = createAsyncThunk(
  'admin/login',
  async (credentials: { email: string; password: string }) => {
    const response = await adminApi.login(credentials);
    return response.data;
  }
);

export const logoutAdmin = createAsyncThunk(
  'admin/logout',
  async () => {
    await adminApi.logout();
  }
);

export const fetchAdminProfile = createAsyncThunk(
  'admin/fetchProfile',
  async () => {
    const response = await adminApi.getProfile();
    return response.data;
  }
);

export const fetchNotifications = createAsyncThunk(
  'admin/fetchNotifications',
  async () => {
    const response = await adminApi.getNotifications();
    return response.data;
  }
);

const adminSlice = createSlice({
  name: 'admin',
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
    clearError: (state) => {
      state.error = null;
    },
    toggleSidebar: (state) => {
      state.sidebarCollapsed = !state.sidebarCollapsed;
    },
    setSidebarCollapsed: (state, action: PayloadAction<boolean>) => {
      state.sidebarCollapsed = action.payload;
    },
    addNotification: (state, action: PayloadAction<Notification>) => {
      state.notifications.unshift(action.payload);
    },
    markNotificationAsRead: (state, action: PayloadAction<string>) => {
      const notification = state.notifications.find(n => n.id === action.payload);
      if (notification) {
        notification.read = true;
      }
    },
    clearNotifications: (state) => {
      state.notifications = [];
    },
  },
  extraReducers: (builder) => {
    builder
      // Login
      .addCase(loginAdmin.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(loginAdmin.fulfilled, (state, action) => {
        state.isLoading = false;
        state.isAuthenticated = true;
        state.user = action.payload.user;
      })
      .addCase(loginAdmin.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.error.message || 'Login failed';
      })
      // Logout
      .addCase(logoutAdmin.fulfilled, (state) => {
        state.user = null;
        state.isAuthenticated = false;
        state.notifications = [];
      })
      // Fetch Profile
      .addCase(fetchAdminProfile.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchAdminProfile.fulfilled, (state, action) => {
        state.isLoading = false;
        state.user = action.payload;
        state.isAuthenticated = true;
      })
      .addCase(fetchAdminProfile.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.error.message || 'Failed to fetch profile';
      })
      // Fetch Notifications
      .addCase(fetchNotifications.fulfilled, (state, action) => {
        state.notifications = action.payload;
      });
  },
});

export const {
  setLoading,
  setError,
  clearError,
  toggleSidebar,
  setSidebarCollapsed,
  addNotification,
  markNotificationAsRead,
  clearNotifications,
} = adminSlice.actions;

export default adminSlice.reducer;

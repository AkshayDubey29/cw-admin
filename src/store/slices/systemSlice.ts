import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface SystemMetrics {
  cpu: number;
  memory: number;
  disk: number;
  network: number;
  activeUsers: number;
  totalRequests: number;
  errorRate: number;
}

export interface SystemState {
  metrics: SystemMetrics;
  isLoading: boolean;
  error: string | null;
  theme: 'light' | 'dark';
  language: string;
  timezone: string;
}

const initialState: SystemState = {
  metrics: {
    cpu: 0,
    memory: 0,
    disk: 0,
    network: 0,
    activeUsers: 0,
    totalRequests: 0,
    errorRate: 0,
  },
  isLoading: false,
  error: null,
  theme: 'light',
  language: 'en',
  timezone: 'UTC',
};

const systemSlice = createSlice({
  name: 'system',
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
    setMetrics: (state, action: PayloadAction<SystemMetrics>) => {
      state.metrics = action.payload;
    },
    setTheme: (state, action: PayloadAction<'light' | 'dark'>) => {
      state.theme = action.payload;
    },
    setLanguage: (state, action: PayloadAction<string>) => {
      state.language = action.payload;
    },
    setTimezone: (state, action: PayloadAction<string>) => {
      state.timezone = action.payload;
    },
  },
});

export const {
  setLoading,
  setError,
  setMetrics,
  setTheme,
  setLanguage,
  setTimezone,
} = systemSlice.actions;

export default systemSlice.reducer;

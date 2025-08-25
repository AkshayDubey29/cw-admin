import { configureStore } from '@reduxjs/toolkit';
import adminSlice from './slices/adminSlice';
import userManagementSlice from './slices/userManagementSlice';
import contentManagementSlice from './slices/contentManagementSlice';
import systemSlice from './slices/systemSlice';

export const store = configureStore({
  reducer: {
    admin: adminSlice,
    userManagement: userManagementSlice,
    contentManagement: contentManagementSlice,
    system: systemSlice,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: ['persist/PERSIST', 'persist/REHYDRATE'],
      },
    }),
  devTools: process.env.NODE_ENV !== 'production',
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

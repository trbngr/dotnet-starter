import { StrictMode } from 'react';
import { BrowserRouter } from 'react-router-dom';
import * as ReactDOM from 'react-dom/client';

import { AuthProvider } from "react-oidc-context";
import { onSigninCallback, userManager } from './config';
import { Auth } from './app/auth';


const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);

root.render(
  <StrictMode>
    <AuthProvider userManager={userManager} onSigninCallback={onSigninCallback}>
      <BrowserRouter>
        <Auth />
      </BrowserRouter>
    </AuthProvider>
  </StrictMode>
);

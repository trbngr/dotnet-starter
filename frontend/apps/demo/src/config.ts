import { UserManager, WebStorageStateStore } from 'oidc-client-ts';

export const userManager = new UserManager({
    authority: "http://localhost:8080/realms/deepstaging",
    client_id: "demo-react-app",
    redirect_uri: `${window.location.origin}${window.location.pathname}`,
    post_logout_redirect_uri: window.location.origin,
    userStore: new WebStorageStateStore({ store: window.sessionStorage }),
    monitorSession: true
});

export const onSigninCallback = () => {
    window.history.replaceState({}, document.title, window.location.pathname);
};



import React, { useEffect } from "react";
import { useRouter } from "next/router";
import { useAccount, useDisconnect } from "wagmi";

interface LayoutProps {
  children: React.ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const router = useRouter();
  const { address, isConnected } = useAccount();
  const { disconnect } = useDisconnect();

  const handleDisconnect = () => {
    disconnect();
  };

  // ✅ Redirect to home page when disconnected
  useEffect(() => {
    if (!isConnected) {
      router.replace("/");
    }
  }, [isConnected, router]);

  return (
    <div className="flex flex-col min-h-screen bg-base-200 text-gray-100">
      {/* Header */}
      <header className="navbar bg-base-300 shadow-md px-6 text-white">
        <div className="flex-1">
          <button
            className="btn btn-ghost normal-case text-xl text-white"
            onClick={() => router.push("/")}
          >
            Blockchain Supply Chain
          </button>
        </div>
        <div className="flex-none">
          {isConnected && address && (
            <div className="dropdown dropdown-end">
              <div className="flex items-center gap-2">
                <div className="avatar">
                  <div className="w-10 rounded-full border border-gray-400">
                    <img src="/wallet-icon.png" alt="Wallet" />
                  </div>
                </div>
                <span className="text-sm font-medium text-gray-200">
                  {address.slice(0, 6)}...{address.slice(-4)}
                </span>
                <label tabIndex={0} className="btn btn-ghost btn-xs text-gray-300">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-4 w-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M19 9l-7 7-7-7"
                    />
                  </svg>
                </label>
              </div>
              <ul
                tabIndex={0}
                className="mt-3 z-[1] menu menu-compact dropdown-content p-2 shadow bg-base-300 rounded-box w-52 border border-gray-500 text-white"
              >
                <li>
                  <a onClick={handleDisconnect} className="text-red-400 hover:bg-red-600 hover:text-white p-2 rounded-md">
                    Disconnect
                  </a>
                </li>
              </ul>
            </div>
          )}
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 container mx-auto p-6">{children}</main>

      {/* Footer */}
      <footer className="footer p-10 bg-base-300 text-gray-200 border-t border-gray-500">
        <div>
          <span className="footer-title font-semibold text-lg text-white">Blockchain Supply Chain</span>
          <a className="link link-hover text-gray-300 hover:text-white">About</a>
          <a className="link link-hover text-gray-300 hover:text-white">Contact</a>
          <a className="link link-hover text-gray-300 hover:text-white">Privacy Policy</a>
        </div>
        <div>
          <span className="footer-title font-semibold text-lg text-white">Social</span>
          <a className="link link-hover text-gray-300 hover:text-white">Twitter</a>
          <a className="link link-hover text-gray-300 hover:text-white">LinkedIn</a>
          <a className="link link-hover text-gray-300 hover:text-white">GitHub</a>
        </div>
      </footer>
    </div>
  );
};

export default Layout;

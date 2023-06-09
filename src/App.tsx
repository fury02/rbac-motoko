import React, {useState} from 'react';
import './App.css';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import {HomeComponent} from "./components/HomeComponent";
import NavBarComponent from "./layouts/NavBarComponent";
import {RbacCreateEntityComponent} from "./components/admin/RbacCreateEntityComponent";
import {RolePermissionsComponent} from "./components/admin/RolePermissionsComponent";
import {UserRolesComponent} from "./components/admin/UserRolesComponent";
import {RbacDeleteEntityComponent} from "./components/admin/RbacDeleteEntityComponent";
import {UserRbacInfoComponent} from "./components/admin/UserRbacInfoComponent";
import {PageOneComponent} from "./components/checking_access/pages/PageOneComponent";
import {ArrayViewComponent} from "./components/checking_access/data/ArrayViewComponent";
// import {ArrayViewComponent} from "./components/checking_access/data/ArrayViewComponent";
// import {DocumentationComponent} from "./components/not_included/DocumentationComponent";
// import {PageOneComponent} from "./components/checking_access/pages/PageOneComponent";
// import {RbacCreateEntityComponent} from "./components/admin/RbacCreateEntityComponent";
// import {RolePermissionsComponent} from "./components/admin/RolePermissionsComponent";
// import {UserRolesComponent} from "./components/admin/UserRolesComponent";
// import {RbacDeleteEntityComponent} from "./components/admin/RbacDeleteEntityComponent";
// import {UserRbacInfoComponent} from "./components/admin/UserRbacInfoComponent";
function App() {

  return (
      <div className="App">
        <BrowserRouter>
          <Routes>
            <Route path='/' element={<NavBarComponent></NavBarComponent>}>
              <Route index element={<HomeComponent/>}></Route>
              {/*  /!*<Route path='admin' element={<AdminComponent/>}></Route>*!/*/}
              {/*  /!*<Route path='doc' element={<DocumentationComponent/>}></Route>*!/*/}
              <Route path='checking_access/pages/page_one'element={<PageOneComponent/>}></Route>
              <Route path='checking_access/data/check'element={<ArrayViewComponent/>}></Route>
              <Route path='admin/create'element={<RbacCreateEntityComponent/>}></Route>
              <Route path='admin/bind/role_permissions'element={<RolePermissionsComponent/>}></Route>
              <Route path='admin/bind/user_roles'element={<UserRolesComponent/>}></Route>
              <Route path='admin/delete'element={<RbacDeleteEntityComponent/>}></Route>
              <Route path='admin/user_rbac_info'element={<UserRbacInfoComponent/>}></Route>
              <Route path='*' element={<Navigate replace to="/"/>}></Route>
            </Route>
          </Routes>
        </BrowserRouter>
      </div>
  );
}

export default App;

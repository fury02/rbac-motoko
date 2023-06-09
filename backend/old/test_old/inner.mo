import Types "../rbac/types";
import Interface "interface";

import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Principal "mo:base/Principal";

//1)dfx canister update-settings rbac --add-controller <canister_id_rbac>
//2)dfx canister call rbac initialization
//3)dfx canister call rbac add_admin "(principal \"<canister_id_test>\")"

actor InnerTest {

        type Errors = Types.Errors;
        type Admin = Types.Admin;
        type User = Types.User;
        type Role = Types.Role;
        type Permission = Types.Permission;
        type Action = Types.Action;

        let canister_id = "be2us-64aaa-aaaaa-qaabq-cai";

        // RUN COMMANDS:
        //     1)
        // - dfx start --clean
        //     2)
        // - dfx deploy
        //     3) Edit canister_id rbac
        // - dfx canister update-settings rbac --add-controller bd3sg-teaaa-aaaaa-qaaba-cai
        //     4)
        // - dfx canister call rbac initialization
        //     5) This tets canister
        // - dfx canister call rbac add_admin "(principal \"be2us-64aaa-aaaaa-qaabq-cai\")"
        //     6)
        // - dfx deploy
        //     7)

        let user = "53raf-ibe5d-ffv7e-uvaqa-nqbak-xczww-ajexj-6u5zz-4fzha-bz4on-uae"; //stoic
        let user2 = "ldsqz-2i24u-crbm3-aarqj-nxbrc-iwzsf-bmzx2-ei3bj-vcac5-aup4j-gqe"; //stoic
        let user3 = "ixrwc-uyxws-zdcjr-4wrcm-wsjkn-7avh5-eire6-v7u4r-cudh7-xbwg6-pae"; //stoic (chromium)
        let user4 = "aq5rf-bvyxa-rro7g-nbmm6-tjlhp-7azye-m3owq-y4sdu-bgydm-3uq37-kae";

        let admin_stoic = "uolge-vezhl-ofixo-6gnvl-3geuf-27q4b-niavt-hgi53-gvivv-xjthx-lae"; //stoic
        let admin_debug_stoic = "jg232-gb2jq-fxffi-fctj6-daeup-4gwlb-2z5vk-6hpgr-3vlxy-pwm2m-aqe"; //stoic

        let rbac : Interface.IActor = actor (canister_id);

        public func test() : async () {
                // Part 1 is related to the following parts: part_2; part_3
                await test_rbac(); //part 1
                await test_rbac_web(); //part 2
                await test_rbac_rp();//part 2
        };

        public func test_rbac() : async () {

                Debug.print("start first part" # debug_show ());

                let caller = await rbac.whoami_caller();
                Debug.print("caller: " # debug_show (caller));

                //assert admin - controller
                let controllers : [Admin] = await rbac.controllers();
                let admins : [Admin] = await rbac.admins();

                let role_test : Role = "Role-test";
                let role_web : Role = "Role-web";
                let role_array_r : Role = "Role-array-r"; //read
                let role_array_rw : Role = "Role-array-rw"; //read write
                let role_array_rwd : Role = "Role-array-rwd"; //read write delete
                let role_empty : Role = "Emty";
                let role_new : Role = "New";
                let role_xy : Role = "xy";

                let permission_test : Permission = "Permission";
                let permission_empty : Permission = "empty";
                let permission_web_access_home : Permission = "Page:home";
                let permission_array_read : Permission = "Array-read";
                let permission_array_write : Permission = "Array-write";
                let permission_array_delete : Permission = "Array-delete";
                let permission_x : Permission = "x";
                let permission_y : Permission = "y";

                //Admins
                assert (Array.size<Admin>(controllers) > 0);
                assert (Array.size<Admin>(admins) > 0);
                assert (Array.size<Admin>(admins) == Array.size<Admin>(controllers));

                Debug.print("admin :" # debug_show (Nat.toText(Array.size<Admin>(admins))));
                Debug.print("controllers :" # debug_show (Nat.toText(Array.size<Admin>(controllers))));

                let adm : Result.Result<?Admin, Errors> = await rbac.add_admin(Principal.fromText(admin_stoic));
                switch (adm) {
                        case (#ok(v)) {
                                Debug.print("add_admin: " # debug_show (#ok));
                        };
                        case (#err(e)) {
                                Debug.print("add_admin: " # debug_show (#err));
                        };
                };
                let adm2 : Result.Result<?Admin, Errors> = await rbac.add_admin(Principal.fromText(admin_debug_stoic));

                //User
                let u : Result.Result<?User, Errors> = await rbac.add_user(Principal.fromText(user));
                let u2 : Result.Result<?User, Errors> = await rbac.add_user(Principal.fromText(user2));

                let users : [User] = await rbac.users();
                assert (Array.size<Admin>(users) == 2);
                Debug.print("users count: " # debug_show (Array.size<Admin>(users)));

                //Role
                let added_role_test : Result.Result<?Role, Errors> = await rbac.add_role(role_test);
                let added_role_w : Result.Result<?Role, Errors> = await rbac.add_role(role_web);
                let added_role_r : Result.Result<?Role, Errors> = await rbac.add_role(role_array_r);
                let added_role_rw : Result.Result<?Role, Errors> = await rbac.add_role(role_array_rw);
                let added_role_rwd : Result.Result<?Role, Errors> = await rbac.add_role(role_array_rwd);
                let added_role_empt : Result.Result<?Role, Errors> = await rbac.add_role(role_empty);

                let added_roles : [Role] = await rbac.roles();

                Debug.print("added roles: " # debug_show (added_roles));
                assert (Array.size<Role>(added_roles) == 6);
                Debug.print("added roles count: " # debug_show (Array.size<Role>(added_roles)));

                let added_role_new : Result.Result<?Role, Errors> = await rbac.add_role(role_new);

                let new_added_roles : [Role] = await rbac.roles();
                Debug.print("new added roles: " # debug_show (new_added_roles));
                assert (Array.size<Role>(new_added_roles) == 7);

                //Permission

                let added_permission0 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_test);
                let added_permission1 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_array_read);
                let added_permission2 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_array_write);
                let added_permission3 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_array_delete);
                let added_permission4 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_web_access_home);

                let added_permissions : [Permission] = await rbac.permissions();

                Debug.print("added permissions : " # debug_show (added_permissions));
                assert (Array.size<Permission>(added_permissions) == 5);
                Debug.print("added permissions count: " # debug_show (Array.size<Permission>(added_permissions)));

                let added_permission5 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_x);
                let added_permission6 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_y);

                let new_added_permissions : [Role] = await rbac.permissions();

                Debug.print("new added permissions : " # debug_show (new_added_permissions));
                assert (Array.size<Permission>(new_added_permissions) == 7);
                Debug.print("new added permissions count: " # debug_show (Array.size<Permission>(new_added_permissions)));

                //Bind role-permission
                let bv : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_test, permission_test);
                let bv2 : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_test, permission_x);
                let bv3 : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_test, permission_y);
                //Err
                let fake = "...";
                let bind_err : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_test, fake);
                switch (bind_err) {
                        case (#ok(v)) {
                                Debug.print("(true) bind permission error: " # debug_show (#ok));
                        };
                        case (#err(e)) {
                                Debug.print("(true)bind permission error: " # debug_show (#err));
                        };
                };
                let bind_err2 : Result.Result<?Permission, Errors> = await rbac.bind_permission(fake, permission_y);
                switch (bind_err2) {
                        case (#ok(v)) {
                                Debug.print("(true)bind permission error role: " # debug_show (#ok));
                        };
                        case (#err(e)) {
                                Debug.print("(true)bind permission error role: " # debug_show (#err));
                        };
                };

                let pr : Result.Result<?[Permission], Errors> = await rbac.demand_permissions(role_test);
                switch (pr) {
                        case (#ok(v)) {
                                switch (v) {
                                        case (?v) {
                                                assert (Array.size<Role>(v) == 3);
                                                Debug.print("permissions: " # debug_show (v));
                                        };
                                        case (null) {
                                                Debug.print("permissions size error: " # debug_show ("null"));
                                        };
                                };
                        };
                        case (#err(e)) {
                                Debug.print("permissions size error: " # debug_show (#err));
                        };
                };

                let pru : Result.Result<?[Permission], Errors> = await rbac.unbind_permission(role_test, permission_test);
                let prd : Result.Result<?[Permission], Errors> = await rbac.demand_permissions(role_test);
                switch (prd) {
                        case (#ok(v)) {
                                switch (v) {
                                        case (?v) {
                                                assert (Array.size<Role>(v) == 2);
                                                Debug.print("permissions for role_test delete: " # debug_show (v));
                                        };
                                        case (null) {
                                                Debug.print("permissions role_test size error: " # debug_show ("null"));
                                        };
                                };
                        };
                        case (#err(e)) {
                                Debug.print("permissions role_test size error: " # debug_show (#err));
                        };
                };

                let rwd_bra_r : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_array_rwd, permission_array_read);
                let rwd_bra_w : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_array_rwd, permission_array_write);
                let rwd_bra_d : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_array_rwd, permission_array_delete);
                let prwd : Result.Result<?[Permission], Errors> = await rbac.demand_permissions(role_array_rwd);
                switch (prwd) {
                        case (#ok(v)) {
                                switch (v) {
                                        case (?v) {
                                                assert (Array.size<Role>(v) == 3);
                                                Debug.print("(rwd)permissions: " # debug_show (v));
                                        };
                                        case (null) {
                                                Debug.print("(rwd)permissions size error: " # debug_show ("null"));
                                        };
                                };
                        };
                        case (#err(e)) {
                                Debug.print("(rwd)permissions size error: " # debug_show (#err));
                        };
                };

                let rw_bra_r : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_array_rw, permission_array_read);
                let rw_bra_w : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_array_rw, permission_array_write);
                let prw : Result.Result<?[Permission], Errors> = await rbac.demand_permissions(role_array_rw);
                switch (prw) {
                        case (#ok(v)) {
                                switch (v) {
                                        case (?v) {
                                                assert (Array.size<Role>(v) == 2);
                                                Debug.print("(rw)permissions: " # debug_show (v));
                                        };
                                        case (null) {
                                                Debug.print("(rw)permissions size error: " # debug_show ("null"));
                                        };
                                };
                        };
                        case (#err(e)) {
                                Debug.print("(rw)permissions size error: " # debug_show (#err));
                        };
                };

                //User role add

                let add_user_role_rwd : Result.Result<?Role, Errors> = await rbac.bind_role(Principal.fromText(user), role_array_rwd);
                let add_user2_role_rw : Result.Result<?Role, Errors> = await rbac.bind_role(Principal.fromText(user2), role_array_rw);
                let add_user2_role_test : Result.Result<?Role, Errors> = await rbac.bind_role(Principal.fromText(user2), role_test);
                let add_user2_role_web : Result.Result<?Role, Errors> = await rbac.bind_role(Principal.fromText(user2), role_web);
                let add_user2_role_empty : Result.Result<?Role, Errors> = await rbac.bind_role(Principal.fromText(user2), role_empty);
                let user_roles : Result.Result<?[Role], Errors> = await rbac.demand_roles_unsafe(Principal.fromText(user));
                let user2_roles : Result.Result<?[Role], Errors> = await rbac.demand_roles_unsafe(Principal.fromText(user2));
                switch (user_roles) {
                        case (#ok(v)) {
                                switch (v) {
                                        case (?v) {
                                                assert (Array.size<Role>(v) == 1);
                                                Debug.print("(role_rwd)user roles: " # debug_show (v));
                                        };
                                        case (null) {
                                                Debug.print("(role_rwd)user roles: " # debug_show ("null"));
                                        };
                                };
                        };
                        case (#err(e)) {
                                Debug.print("(role_rwd)user roles size error: " # debug_show (#err));
                        };
                };
                switch (user2_roles) {
                        case (#ok(v)) {
                                switch (v) {
                                        case (?v) {
                                                assert (Array.size<Role>(v) == 4);
                                                Debug.print("(role_rw; test; web-home)user2 roles: " # debug_show (v));
                                        };
                                        case (null) {
                                                Debug.print("(role_rw; test; web-home)user2 roles: " # debug_show ("null"));
                                        };
                                };
                        };
                        case (#err(e)) {
                                Debug.print("(role_rw; test; web-home)user2 roles size error: " # debug_show (#err));
                        };
                };

                let unbind_user2_role_test : Result.Result<?[Role], Errors> = await rbac.unbind_role(Principal.fromText(user2), role_test);
                let new_user2_roles : Result.Result<?[Role], Errors> = await rbac.demand_roles_unsafe(Principal.fromText(user2));
                switch (new_user2_roles) {
                        case (#ok(v)) {
                                switch (v) {
                                        case (?v) {
                                                assert (Array.size<Role>(v) == 3);
                                                Debug.print("(role_rw; web-home)user2 roles: " # debug_show (v));
                                        };
                                        case (null) {
                                                Debug.print("(role_rw; web-home)user2 roles: " # debug_show ("null"));
                                        };
                                };
                        };
                        case (#err(e)) {
                                Debug.print("(role_rw; web-home)user2 roles size error: " # debug_show (#err));
                        };
                };
 
                let user_permissions : [Permission] = await rbac.demand_user_permissions_unsafe(Principal.fromText(user));
                assert (Array.size<Permission>(user_permissions) == 3);
                Debug.print("user permissions: " # debug_show (user_permissions));

                let user2_permissions : [Permission] = await rbac.demand_user_permissions_unsafe(Principal.fromText(user2));
                assert (Array.size<Permission>(user2_permissions) == 2);
                Debug.print("user2 permissions: " # debug_show (user2_permissions));

                let added_permission7 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_empty);

                // let role_empty_permission_ : Result.Result<?Permission, Errors> =
                //         await rbac.bind_permission(role_empty, permission_empty);
                let role_web_permission_web_access_home : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_web, permission_web_access_home);

                let new_user2_permissions : [Permission] = await rbac.demand_user_permissions_unsafe(Principal.fromText(user2));
                assert (Array.size<Permission>(new_user2_permissions) == 3);
                Debug.print("new user2 permissions: " # debug_show (new_user2_permissions));

                Debug.print("end first part" # debug_show ());
        };
 
        //For Web Test
        //Role
        let role_user_web_access_pages : Role = "WebAccessPages";
        //Permission
        let permission_access_page : Permission = "UIPageOneComponent";
        let permission_access_page2 : Permission = "UIPageTwoComponent";

        let user_roles_count : Nat = 1;
        let user_permission_count : Nat = 2;

        public func test_rbac_web() : async () {

                Debug.print("start part " # debug_show (2));

                //New user
                let u3 : Result.Result<?User, Errors> = await rbac.add_user(Principal.fromText(user3));

                //New Role
                //Role add
                let added_web_check_access_page : Result.Result<?Role, Errors> = await rbac.add_role(role_user_web_access_pages);
                //Permission add
                let added_permission_access_page : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_access_page);
                let added_permission_access_page2 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission_access_page2);
                //Bind role for permission
                let bv : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_user_web_access_pages, permission_access_page);
                let bv2 : Result.Result<?Permission, Errors> = await rbac.bind_permission(role_user_web_access_pages, permission_access_page2);
                //Bind role for user
                let bind_role : Result.Result<?Role, Errors> = await rbac.bind_role(Principal.fromText(user3), role_user_web_access_pages);
                //check
                let user3_roles : Result.Result<?[Role], Errors> = await rbac.demand_roles_unsafe(Principal.fromText(user3));
                switch (user3_roles) {
                        case (#ok(v)) {
                                switch (v) {
                                        case (?v) {
                                                assert (Array.size<Role>(v) == user_roles_count);
                                                Debug.print("(role_rwd)user3 roles: " # debug_show (v));
                                        };
                                        case (null) {
                                                Debug.print("(role_rwd)user3 roles: " # debug_show ("null"));
                                        };
                                };
                        };
                        case (#err(e)) {
                                Debug.print("(role_web_check_access_page )user roles size error: " # debug_show (#err));
                        };
                };
                let user3_permissions : [Permission] = await rbac.demand_user_permissions_unsafe(Principal.fromText(user3));
                assert (Array.size<Permission>(user3_permissions) == user_permission_count);
                Debug.print("user 3 permissions: " # debug_show (user3_permissions));

                Debug.print("end part" # debug_show (" 2"));
        };

        //For role permissions bindings
        //Role
        let role : Role = "rl";
        let role2 : Role = "rl2";
        let role3 : Role = "rl3";
        let role4 : Role = "rl4";

        //Permission
        let permission : Permission = "per";
        let permission2 : Permission = "per2";
        let permission3 : Permission = "per3";
        let permission4 : Permission = "per4";
        let permission5 : Permission = "per5";

        public func test_rbac_rp() : async () {

                Debug.print("start part " # debug_show (3));

                //New user
                let u4 : Result.Result<?User, Errors> = await rbac.add_user(Principal.fromText(user4));

                let roles : [Role] = await rbac.roles();
                let permissions : [Permission] = await rbac.permissions();

                let size_roles = Array.size<Role>(roles);
                let size_permissions = Array.size<Role>(permissions);

                Debug.print("size_roles: " # debug_show (size_roles));
                Debug.print("size_permissions: " # debug_show (size_permissions));

                //New Role
                //Role add
                let added_role : Result.Result<?Role, Errors> = await rbac.add_role(role);
                let added_role2 : Result.Result<?Role, Errors> = await rbac.add_role(role2);
                let added_role3 : Result.Result<?Role, Errors> = await rbac.add_role(role3);
                let added_role4 : Result.Result<?Role, Errors> = await rbac.add_role(role4);

                //Permission add
                let added_permission : Result.Result<?Permission, Errors> = await rbac.add_permission(permission);
                let added_permission2 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission2);
                let added_permission3 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission3);
                let added_permission4 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission4);
                let added_permission5 : Result.Result<?Permission, Errors> = await rbac.add_permission(permission5);

                let new_roles : [Role] = await rbac.roles();
                let new_permissions : [Permission] = await rbac.permissions();

                let new_size_roles = Array.size<Role>(new_roles);
                let new_size_permissions = Array.size<Role>(new_permissions);

                Debug.print("new_size_roles: " # debug_show (new_size_roles));
                Debug.print("new_size_permissions: " # debug_show (new_size_permissions));

                assert (new_size_roles == size_roles + 4);
                assert (new_size_permissions == size_permissions + 5);

                let delete_role4 = await rbac.delete_role(role4);
                Debug.print("delete role4: " # debug_show (delete_role4));

                let delete_permission5 = await rbac.delete_permission(permission5);
                Debug.print("delete permission5: " # debug_show (delete_permission5));

                //Bind role for permission
                //role1
                let bv : Result.Result<?Permission, Errors> = await rbac.bind_permission(role, permission);
                let bv2 : Result.Result<?Permission, Errors> = await rbac.bind_permission(role, permission2);
                let bv3 : Result.Result<?Permission, Errors> = await rbac.bind_permission(role, permission3);

                //role2
                let bv4 : Result.Result<?Permission, Errors> = await rbac.bind_permission(role2, permission3);
                let bv5 : Result.Result<?Permission, Errors> = await rbac.bind_permission(role2, permission4);

                let bind_role : Result.Result<?Role, Errors> = await rbac.bind_role(Principal.fromText(user4), role);
                let bind_role2 : Result.Result<?Role, Errors> = await rbac.bind_role(Principal.fromText(user4), role2);

                let delete_permission3 = await rbac.delete_permission(permission3);
                let delete_permission4 = await rbac.delete_permission(permission4);

                Debug.print("delete permission3: " # debug_show (delete_permission3));
                Debug.print("delete permission4: " # debug_show (delete_permission4));

                let delete_role = await rbac.delete_role(role);
                let delete_role2 = await rbac.delete_role(role2);

                Debug.print("delete_role: " # debug_show (delete_role));
                Debug.print("delete_role2: " # debug_show (delete_role2));

                let new_roles2 : [Role] = await rbac.roles();
                let new_permissions2 : [Permission] = await rbac.permissions();

                let new_size_roles2 = Array.size<Role>(new_roles2);
                let new_size_permissions2 = Array.size<Role>(new_permissions2);

                assert (new_size_roles == new_size_roles2 + 1 );
                assert (new_size_permissions == new_size_permissions2 + 1);

                let ub = await rbac.unbind_permission(role2, permission4);
                let ub2 = await rbac.unbind_permission(role2, permission3);

                let new_delete_permission4 = await rbac.delete_permission(permission4);
                Debug.print("new_delete_permission4: " # debug_show (delete_permission4));

                let err_delete_role2 = await rbac.delete_role(role2);
                Debug.print("err_delete_role2: " # debug_show (err_delete_role2));

                let ubu = await rbac.unbind_role(Principal.fromText(user4), role2);

                let not_err_delete_role2 = await rbac.delete_role(role2);
                Debug.print("not_err_delete_role2: " # debug_show (not_err_delete_role2));

                let new_roles3 : [Role] = await rbac.roles();
                let new_permissions3 : [Permission] = await rbac.permissions();

                let new_size_roles3 = Array.size<Role>(new_roles3);
                let new_size_permissions3 = Array.size<Role>(new_permissions3);

                assert (new_size_roles == new_size_roles3 + 2);
                assert (new_size_permissions == new_size_permissions3 + 2);

                Debug.print("end part" # debug_show (" 3"));
        };
};

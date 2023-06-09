import Types "../rbac/types/types";
import IRbac "../rbac/interfaces/irbac";

import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Principal "mo:base/Principal";

import Fuzz "mo:fuzz";
import Prng "mo:prng";

// - dfx canister update-settings rbac --add-controller <canister_id_rbac>
// - dfx canister call rbac _init

actor InnerTest {

    type Errors = Types.Errors;
    type Admin = Types.Admin;
    type User = Types.User;
    type Role = Types.Role;
    type Permission = Types.Permission;
    type Admins = Types.Admins;
    type Users = Types.Users;
    type Roles = Types.Roles;
    type Permissions = Types.Permissions;
    type ListRelatedRP = Types.ListRelatedRP;
    type RelatedRP = Types.RelatedRP;
    type JTI = Types.JTI;
    type Token = Types.Token;
    type AuthClient = Types.AuthClient;

    //#1: dfx canister update-settings rbac --add-controller <canister_id_test>
    //#2: dfx canister update-settings rbac --add-controller <canister_id_rbac>
    //#3: dfx canister rbac init()

    let rbac_canister_id = "be2us-64aaa-aaaaa-qaabq-cai";

    let user = "53raf-ibe5d-ffv7e-uvaqa-nqbak-xczww-ajexj-6u5zz-4fzha-bz4on-uae";
    let user1 = "iaeem-mynif-b6bhl-yyi6s-hut2v-qxduq-lpzfe-qppeh-wqqog-5ghyp-xqe";
    let user2 = "ldsqz-2i24u-crbm3-aarqj-nxbrc-iwzsf-bmzx2-ei3bj-vcac5-aup4j-gqe";
    let user3 = "ixrwc-uyxws-zdcjr-4wrcm-wsjkn-7avh5-eire6-v7u4r-cudh7-xbwg6-pae";
    let user4 = "aq5rf-bvyxa-rro7g-nbmm6-tjlhp-7azye-m3owq-y4sdu-bgydm-3uq37-kae";
    let admin_stoic = "4zvo4-2i2hg-3ddkb-siywv-x3u4v-6tq25-iclaf-2vp65-2n4wl-qjb77-kqe";
    let admin_debug_stoic = "jg232-gb2jq-fxffi-fctj6-daeup-4gwlb-2z5vk-6hpgr-3vlxy-pwm2m-aqe";

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

    let rbac : IRbac.IRbac = actor (rbac_canister_id);

    private func init() : async () {
        let adms = await rbac.init();
        Debug.print("init" # debug_show (adms));
    };

    public func add_user() : async () {
        var auth_client = await rbac.request_client();
        switch (auth_client) {
            case (#err(e)) {};
            case (#ok(authclient)) {
                var u1 = await rbac.add_user(Principal.fromText("b77ix-eeaaa-aaaaa-qaada-cai"), authclient);
            };
        };
    };

    public func test() : async () {
        await init();
        await test_rbac(); //part
        // await test_rbac_web(); //part
    };

    public func test_rbac() : async () {
        Debug.print("start #1" # debug_show ("test_rbac()"));

        //#1 caller (ping)
        let caller = await rbac.whoami_caller();
        Debug.print("caller: " # debug_show (caller));

        //#1: dfx canister update-settings rbac --add-controller <canister_id_test>
        //#2: dfx canister update-settings rbac --add-controller <canister_id_rbac>
        //#3: dfx canister rbac init()
        Debug.print(" ");
        Debug.print("#1.1 Admins and Users");
        var count_users = 0;
        var users : Result.Result<Users, Errors> = await rbac._users_();
        switch (users) {
            case (#err(e)) {
                Debug.print("rbac.users() #err(e)  " # debug_show (e));
            };
            case (#ok(v)) {
                count_users := Array.size<User>(v);
                assert (count_users != 0);
                Debug.print("count_users  " # debug_show (count_users));
            };
        };
        //add admin
        var user_admin : Result.Result<User, Errors> = await rbac.add_admin(Principal.fromText(user));
        switch (user_admin) {
            case (#err(e)) {};
            case (#ok(v)) { count_users := count_users + 1 };
        };
        users := await rbac._users_();
        switch (users) {
            case (#err(e)) {
                Debug.print("rbac.users() #err(e)  " # debug_show (e));
            };
            case (#ok(v)) {
                Debug.print("count_users  " # debug_show (count_users));
                assert (Array.size<User>(v) == count_users);
            };
        };
        //delete admin
        user_admin := await rbac.delete_admin(Principal.fromText(user));
        switch (user_admin) {
            case (#err(e)) {};
            case (#ok(v)) { count_users := count_users - 1 };
        };
        users := await rbac._users_();
        switch (users) {
            case (#err(e)) {
                Debug.print("rbac.users() #err(e)  " # debug_show (e));
            };
            case (#ok(v)) {
                Debug.print("count_users  " # debug_show (count_users));
                assert (Array.size<User>(v) == count_users);
            };
        };
        //add admin
        user_admin := await rbac.delete_admin(Principal.fromText(admin_stoic));
        switch (user_admin) {
            case (#err(e)) {};
            case (#ok(v)) { count_users := count_users - 1 };
        };
        user_admin := await rbac.add_admin(Principal.fromText(admin_stoic));
        switch (user_admin) {
            case (#err(e)) {};
            case (#ok(v)) { count_users := count_users + 1 };
        };
        users := await rbac._users_();
        switch (users) {
            case (#err(e)) {
                Debug.print("rbac.users() #err(e)  " # debug_show (e));
            };
            case (#ok(v)) { count_users := Array.size<User>(v) };
        };
        Debug.print(" ");
        Debug.print("#1.2 Auth Clients");
        //add auth
        var auth_client = await rbac.request_client();
        switch (auth_client) {
            case (#err(e)) {
                Debug.print("rbac.request_client() #err(e)  " # debug_show (e));
            };
            case (#ok(v)) { Debug.print("client  " # debug_show (auth_client)) };
        };
        assert (await rbac.valid_client());
        switch (auth_client) {
            case (#err(e)) {};
            case (#ok(v)) { ignore await rbac.delete_client(v) };
        };
        assert ((await rbac.valid_client()) == false);
        auth_client := await rbac.request_client();
        switch (auth_client) {
            case (#err(e)) {
                Debug.print("rbac.request_client() #err(e)  " # debug_show (e));
            };
            case (#ok(v)) { Debug.print("client  " # debug_show (auth_client)) };
        };
        assert (await rbac.valid_client());
        Debug.print(" ");
        Debug.print("#1.3 Users store CRUD");
        auth_client := await rbac.request_client();
        switch (auth_client) {
            case (#err(e)) {};
            case (#ok(authclient)) {

                var u1 = await rbac.add_user(Principal.fromText(user1), authclient);
                var u2 = await rbac.add_user(Principal.fromText(user2), authclient);
                var u3 = await rbac.add_user(Principal.fromText(user3), authclient);
                var u4 = await rbac.add_user(Principal.fromText(user4), authclient);

                var cu1 = await rbac.contains_user(Principal.fromText(user1), authclient);
                var cu2 = await rbac.contains_user(Principal.fromText(user2), authclient);
                var cu3 = await rbac.contains_user(Principal.fromText(user3), authclient);
                var cu4 = await rbac.contains_user(Principal.fromText(user4), authclient);

                switch (cu1) {
                    case (#err(e)) {
                        Debug.print("add_user() " # debug_show (e));
                    };
                    case (#ok(cu1)) {
                        assert (Principal.equal(cu1, Principal.fromText(user1)));
                    };
                };
                switch (cu3) {
                    case (#err(e)) {
                        Debug.print("add_user() " # debug_show (e));
                    };
                    case (#ok(cu3)) {
                        assert (Principal.equal(cu3, Principal.fromText(user3)));
                    };
                };
                switch (cu4) {
                    case (#err(e)) {
                        Debug.print("add_user() " # debug_show (e));
                    };
                    case (#ok(cu4)) {
                        assert (Principal.equal(cu4, Principal.fromText(user4)));
                    };
                };
                u3 := await rbac.delete_user(Principal.fromText(user3), authclient);
                u4 := await rbac.delete_user(Principal.fromText(user4), authclient);

                cu3 := await rbac.contains_user(Principal.fromText(user3), authclient);
                cu4 := await rbac.contains_user(Principal.fromText(user4), authclient);

                switch (cu3) {
                    case (#err(e)) {
                        Debug.print("add_user() " # debug_show (e));
                    };
                    case (#ok(cu3)) {
                        assert (Principal.equal(cu3, Principal.fromText(user3)) == false);
                    };
                };
                switch (cu4) {
                    case (#err(e)) {
                        Debug.print("add_user() " # debug_show (e));
                    };
                    case (#ok(cu4)) {
                        assert (Principal.equal(cu4, Principal.fromText(user4)) == false);
                    };
                };
            };
        };

        Debug.print(" ");
        Debug.print("#1.4 Rolse Permissions");
        auth_client := await rbac.request_client();
        switch (auth_client) {
            case (#err(e)) {};
            case (#ok(authclient)) {
                var rt = await rbac.add_role(role_test, authclient);
                var r2 = await rbac.add_role(role_web, authclient);
                var rar = await rbac.add_role(role_array_r, authclient);
                var rarw = await rbac.add_role(role_array_rw, authclient);
                var rarwd = await rbac.add_role(role_array_rwd, authclient);
                var re = await rbac.add_role(role_empty, authclient);
                var rn = await rbac.add_role(role_new, authclient);
                var rxy = await rbac.add_role(role_xy, authclient);

                var pt = await rbac.add_permission(permission_test, authclient);
                var pe = await rbac.add_permission(permission_empty, authclient);
                var pwah = await rbac.add_permission(permission_web_access_home, authclient);
                var par = await rbac.add_permission(permission_array_read, authclient);
                var paw = await rbac.add_permission(permission_array_write, authclient);
                var pad = await rbac.add_permission(permission_array_delete, authclient);
                var px = await rbac.add_permission(permission_x, authclient);
                var py = await rbac.add_permission(permission_y, authclient);

                var grt = await rbac.get_role(role_test, authclient);
                var gpt = await rbac.get_permission(permission_test, authclient);

                switch (grt) {
                    case (#err(e)) { assert (false) };
                    case (#ok(v)) {
                        Debug.print("role_test " # debug_show (v));
                        assert (true);
                    };
                };
                switch (gpt) {
                    case (#err(e)) { assert (false) };
                    case (#ok(v)) {
                        Debug.print("permission_test " # debug_show (v));
                        assert (true);
                    };
                };
                var dgrt = await rbac.delete_role(role_test, authclient);
                var dgpt = await rbac.delete_permission(permission_test, authclient);

                grt := await rbac.get_role(role_test, authclient);
                gpt := await rbac.get_permission(permission_test, authclient);
                switch (grt) {
                    case (#err(e)) {
                        Debug.print("role_test " # debug_show (e));
                        assert (true);
                    };
                    case (#ok(v)) { assert (false) };
                };
                switch (gpt) {
                    case (#err(e)) {
                        Debug.print("permission_test " # debug_show (e));
                        assert (true);
                    };
                    case (#ok(v)) { assert (false) };
                };
                rt := await rbac.add_role(role_test, authclient);
                pt := await rbac.add_permission(permission_test, authclient);
            };
        };
        Debug.print("end #1" # debug_show ("test()"));

        Debug.print(" ");
        Debug.print("#1.5 Bindings User Rolse Permissions");
        auth_client := await rbac.request_client();
        switch (auth_client) {
            case (#err(e)) {};
            case (#ok(authclient)) {

                //Bind role-permission
                let bv = await rbac.bind_permission(permission_test, role_test, authclient);
                let bv2 = await rbac.bind_permission(permission_x, role_test, authclient);
                let bv3 = await rbac.bind_permission(permission_y, role_test, authclient);
                let bv4 = await rbac.bind_permission(permission_y, role_xy, authclient);
                let bv5 = await rbac.bind_permission(permission_x, role_xy, authclient);
                Debug.print("bind_permission " # debug_show (bv));
                Debug.print("bind_permission " # debug_show (bv2));
                Debug.print("bind_permission " # debug_show (bv3));

                let fake_role = "fake_role";
                let fake_permission = "fake_permission";
                let fbv = await rbac.bind_permission(permission_test, fake_role, authclient);
                let fbv2 = await rbac.bind_permission(fake_permission, role_test, authclient);
                Debug.print("bind_permission " # debug_show (fbv));
                Debug.print("bind_permission " # debug_show (fbv2));
                switch (fbv) {
                    case (#err(e)) { assert (true) };
                    case (#ok(v)) { assert (false) };
                };
                switch (fbv2) {
                    case (#err(e)) { assert (true) };
                    case (#ok(v)) { assert (false) };
                };

                let obj = await rbac.get_role(role_test, authclient);
                let obj2 = await rbac.get_role(role_xy, authclient);
                let obj3 = await rbac.get_permission(permission_test, authclient);
                let obj4 = await rbac.get_permission(permission_x, authclient);
                let obj5 = await rbac.get_permission(permission_y, authclient);
                Debug.print("role_test " # debug_show (obj));
                Debug.print("role_xy " # debug_show (obj2));
                Debug.print("permission_test " # debug_show (obj3));
                Debug.print("permission_x " # debug_show (obj4));
                Debug.print("permission_y " # debug_show (obj5));
            };
        };
        Debug.print("end");
    };
};

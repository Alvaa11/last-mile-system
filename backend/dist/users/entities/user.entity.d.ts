export declare enum UserRole {
    DRIVER = "driver",
    ADMIN = "admin"
}
export declare class User {
    id: string;
    email: string;
    passwordHash: string;
    role: UserRole;
    currentLocation: string;
    createdAt: Date;
    updatedAt: Date;
}

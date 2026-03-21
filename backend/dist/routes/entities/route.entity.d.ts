import { User } from '../../users/entities/user.entity';
export declare enum RouteStatus {
    PLANNED = "PLANNED",
    IN_PROGRESS = "IN_PROGRESS",
    COMPLETED = "COMPLETED",
    CANCELLED = "CANCELLED"
}
export declare class Route {
    id: string;
    driver: User;
    optimizedSequence: number[];
    totalDistance: number;
    status: RouteStatus;
    createdAt: Date;
    updatedAt: Date;
}

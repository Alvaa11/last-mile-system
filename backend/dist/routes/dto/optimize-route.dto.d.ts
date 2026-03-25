export declare class LocationDto {
    id: string;
    latitude: number;
    longitude: number;
}
export declare class OptimizeRouteDto {
    depot: LocationDto;
    deliveries: LocationDto[];
}

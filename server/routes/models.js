// User: {
//     id: string; <-- hashString(email)
//     name: string;
//     email: string;
//     password: string; c<-- bcrypt.hash(password, 10)
// }

// Wishlist: {
//     id: string; <-- uuidv4()
//     userId: string;
//     products: [string]; <-- product IDs
// }

// Product: {
//     id: string; <-- hashString(name)
//     name: string;
//     description: string;
//     price: number;
//     quantity: number;
//     imageURL: string;
//     inventory: string;
// }

// Review: {
//     id: string; <-- uuidv4()
//     userId: string;
//     productId: string;
//     verified: boolean;
//     rating: number;
//     comment: string;
// }

// Order: {
//     id: string; <-- hashString(Date.now().toString())
//     userId: string; 
//     products: [string]; <-- product IDs
//     total: number;
//     address: string;
// }

// History: {
//     id: string; <-- uuidv4()
//     userId: string;
//     products: [string]; <-- product IDs
//     total: number;
//     address: string;
//     status: string;
// }
/**
 * Utilitiy class for dealing with geo related computations.
 * http://www.movable-type.co.uk/scripts/latlong-vincenty-direct.html
 * 
 * @author Max Rudman
 * @since 8/16/2010
 */
public class GeoUtils {
	private static final Double MILE_RATIO = 1.609344;
    private static final Double PI = 3.141592653589793;
    
    public static final Double MAJOR_SEMIAXES = 6378137;
    public static final Double MINOR_SEMIAXES = 6356752.314245;
    public static final Double FLATTENING_RATIO = 1/298.257223563;
    
    public static Double computeDistance(Coordinates point1, Coordinates point2) {
        Double L = toRadians(point2.longitude - point1.longitude);
        Double U1 = Math.atan((1-FLATTENING_RATIO) * Math.tan(toRadians(point1.latitude)));
        Double U2 = Math.atan((1-FLATTENING_RATIO) * Math.tan(toRadians(point2.latitude)));
        Double sinU1 = Math.sin(U1);
        Double cosU1 = Math.cos(U1);
        Double sinU2 = Math.sin(U2);
        Double cosU2 = Math.cos(U2);
          
        Double cosSqAlpha;
        Double lambda = L;
        Double lambdaP;
        Double sinSigma,cos2SigmaM,cosSigma,sigma;
        Integer iterationsLeft = 100;
        do {
            Double sinLambda = Math.sin(lambda);
            Double cosLambda = Math.cos(lambda);
            sinSigma = Math.sqrt((cosU2*sinLambda) * (cosU2*sinLambda) + (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda));
            if (sinSigma == 0) {
                 // co-incident points
                return 0; 
            }
            cosSigma = sinU1*sinU2 + cosU1*cosU2*cosLambda;
            sigma = Math.atan2(sinSigma, cosSigma);
            Double sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
            cosSqAlpha = 1 - sinAlpha*sinAlpha;
            cos2SigmaM = 0;
            if (cosSqAlpha != 0) {
                cos2SigmaM = cosSigma - 2*sinU1*sinU2/cosSqAlpha;
            }
            Double C = FLATTENING_RATIO/16*cosSqAlpha*(4+FLATTENING_RATIO*(4-3*cosSqAlpha));
            lambdaP = lambda;
            lambda = L + (1-C) * FLATTENING_RATIO * sinAlpha * (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));
            iterationsLeft--;
        } while ((Math.abs(lambda-lambdaP) > Math.pow(10, -12)) && (iterationsLeft > 0));

        if (iterationsLeft == 0) {
            // formula failed to converge
            return null;
        }

        Double uSq = cosSqAlpha * (MAJOR_SEMIAXES*MAJOR_SEMIAXES - MINOR_SEMIAXES*MINOR_SEMIAXES) / (MINOR_SEMIAXES*MINOR_SEMIAXES);
        Double A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
        Double B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
        Double deltaSigma = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)-B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
        return MINOR_SEMIAXES*A*(sigma-deltaSigma);
    }
    
    
    public static Coordinates computeDestination(Coordinates start, Double distance, Double direction) {
    	Double s = distance;
    	Double alpha1 = toRadians(direction);
    	Double sinAlpha1 = Math.sin(alpha1);
    	Double cosAlpha1 = Math.cos(alpha1);
    	  
    	Double tanU1 = (1-FLATTENING_RATIO) * Math.tan(toRadians(start.latitude));
    	Double cosU1 = 1 / Math.sqrt((1 + tanU1*tanU1));
    	Double sinU1 = tanU1*cosU1;
    	Double sigma1 = Math.atan2(tanU1, cosAlpha1);
    	Double sinAlpha = cosU1 * sinAlpha1;
    	Double cosSqAlpha = 1 - sinAlpha*sinAlpha;
    	Double uSq = cosSqAlpha * (MAJOR_SEMIAXES*MAJOR_SEMIAXES - MINOR_SEMIAXES*MINOR_SEMIAXES) / (MINOR_SEMIAXES*MINOR_SEMIAXES);
    	Double A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
    	Double B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
    	Double cos2SigmaM,sinSigma,cosSigma,deltaSigma;
    	
    	Double sigma = s / (MINOR_SEMIAXES*A);
    	Double sigmaP = 2*PI;
    	while (Math.abs(sigma-sigmaP) > Math.pow(10,-12)) {
    		cos2SigmaM = Math.cos(2*sigma1 + sigma);
    		sinSigma = Math.sin(sigma);
    		cosSigma = Math.cos(sigma);
    		deltaSigma = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)-B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
    		sigmaP = sigma;
    		sigma = s / (MINOR_SEMIAXES*A) + deltaSigma;
    	}

    	Double tmp = sinU1*sinSigma - cosU1*cosSigma*cosAlpha1;
    	Double lat2 = Math.atan2(sinU1*cosSigma + cosU1*sinSigma*cosAlpha1,(1-FLATTENING_RATIO)*Math.sqrt(sinAlpha*sinAlpha + tmp*tmp));
    	//System.assert(false, 'T:' + lat2 + ';' + toRadians(start.latitude));
    	Double lambda = Math.atan2(sinSigma*sinAlpha1, cosU1*cosSigma - sinU1*sinSigma*cosAlpha1);
    	Double C = FLATTENING_RATIO/16*cosSqAlpha*(4+FLATTENING_RATIO*(4-3*cosSqAlpha));
    	Double L = lambda - (1-C) * FLATTENING_RATIO * sinAlpha * (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));

    	Double revAz = Math.atan2(sinAlpha, -tmp);  // final bearing
    	
    	return new Coordinates(toDegrees(lat2), start.longitude+toDegrees(L));
    }
    
    public static Double toRadians(Double degrees) {
        return degrees / 180.0 * PI;
    }
    
    public static Double toDegrees(Double radians) {
        return radians * 180.0 / PI;
    }
    
    public static Double toMiles(Double kilometers) {
    	return kilometers / MILE_RATIO;
    }
    
    public static Double toKilometers(Double miles) {
    	return miles * MILE_RATIO;
    }
    
    public class Coordinates {
        public Double longitude {get; set;}
        public Double latitude {get; set;}
        
        public Coordinates(Double latitude, Double longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }
        
        public Coordinates(Decimal latitude, Decimal longitude) {
            this.latitude = latitude.doubleValue();
            this.longitude = longitude.doubleValue();
        }
    }
}
uniform vec2 resolution;
uniform float time;
#define PI 3.1415926535897932384626433832795

float hash(in float n)
{
    return fract(sin(n)*43758.5453123);
}


vec4 lineDistort(vec4 cTextureScreen, vec2 uv1){
  float sCount = 900.;
  float nIntensity=0.1;
  float sIntensity=0.2;
  float noiseEntry = 0.0;
  float accelerator= 1000.0;

  // sample the source
  float x = uv1.x * uv1.y * iGlobalTime * accelerator;
  x = mod( x, 13.0 ) * mod( x, 123.0 );
  float dx = mod( x, 0.05 );
  vec3 cResult = cTextureScreen.rgb + cTextureScreen.rgb * clamp( 0.1 + dx * 100.0, 0.0, 1.0 );
  // get us a sine and cosine
  vec2 sc = vec2( sin( uv1.y * sCount ), cos( uv1.y * sCount ) );
  // add scanlines
  cResult += cTextureScreen.rgb * vec3( sc.x, sc.y, sc.x ) * sIntensity;

  // interpolate between source and result by intensity
  cResult = cTextureScreen.rgb + clamp(nIntensity, noiseEntry,1.0 ) * (cResult - cTextureScreen.rgb);

  return vec4(cResult, cTextureScreen.a);
}

void main() {

    vec2 xy = ( ( gl_FragCoord.xy / resolution.xy  )- .5) * 2.;
    xy.x *= resolution.x/resolution.y;

    float length = pow( 2.,53. );
    int id = 0;
    vec2 p = vec2(0.);
    vec3 pp = vec3( 0.,0., .5 );
    vec3 lightDir = vec3( sin( time*0.00000000000001 ), 1., cos( time * 0.00000000000001 ) );

    const int count = 200;
    for( int i = 0; i < count; i++ )
    {
        float an = sin( time * PI * .000001 ) - hash( float(i) ) * PI * 2.;

        float ra = sqrt( hash( an ) );

        p.x = lightDir.x + cos( an ) * ra;
        p.y = lightDir.z + sin( an ) * ra;

        float di = distance( xy, p );
        length = min( length, di );
        if( length == di )
        {
            id = i;
            pp.xy = p;
            pp.z = float( id )/float( count ) * ( -xy.x * 1.25 );
        }
    }

    vec4 o = vec4( pp + vec3( 1.) * ( 1. - max( 0.0, dot( pp, lightDir)) ), 1. );
    gl_FragColor = lineDistort(o, xy);

}

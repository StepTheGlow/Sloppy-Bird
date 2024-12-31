shader_type canvas_item;
 
uniform int xframe = 0;
uniform int yframe = 0;
 
uniform int xframe_count = 6;
uniform int yframe_count = 6;
varying float xframe_size;
varying float yframe_size;
uniform sampler2D height;
uniform vec3 sunPos;
const vec4 shadowBrightness = vec4(0.5, 0.5, 0.5, 1.);
const vec3 pix = vec3(1./32.,1./32.,0.0);
uniform sampler2D emission_teture;
uniform vec4 glow_color : source_color;
uniform vec4 modulate_color : source_color;
 
const int MAX_STEPS = 300;
 
float getHeightRaw(vec2 pos2) {
    vec2 p = pos2;
    
    return texture(height, p).r;
}
 
//This does some slope angle calculations that can make a smoother shadow. I had issues with it not working right so disabled it. Give it a try if you want.
float getHeightRaw2(vec2 pos) {
    vec2 res = 1./pix.xy;
 
      vec2 p = pos * res;
      
      vec2 lerpP = fract(p);
      
      p = floor(p);
      
      p *= pix.xy;
      
      float tl = texture(height, p).r;
      float bl = texture(height, p + pix.zy).r;
      
      float tr = texture(height, p + pix.xz).r;
      float br = texture(height, p + pix.xy).r;
      
      float t = mix(tl, tr, lerpP.x);
      float b = mix(bl, br, lerpP.x);
      
      return mix(t, b, lerpP.y);
}
 
void vertex() {
    xframe_size = 1./float(xframe_count);
    yframe_size = 1./float(yframe_count);
    
    UV = vec2(UV.x*4.+(float(xframe)*xframe_size)-.25,UV.y*4.+(float(yframe)*yframe_size)-.25);
    VERTEX *= 4.;
}
 
void light(){
    vec4 intensity2 = vec4(1000.0,1000.0,1000.0,1000.0);
    float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
    float specularity = (((SPECULAR_SHININESS.r + SPECULAR_SHININESS.g + SPECULAR_SHININESS.b) /3.0) /255.0);
    vec4 tex = texture(TEXTURE,UV);
    vec4 color = mix(tex,LIGHT,specularity)+vec4(1.);
    vec3 reflection = mix(color.rgb,intensity2.rgb,specularity);
    if (COLOR != vec4(.0, .0, .0 , .5)) {
        LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * cNdotL * reflection.rgb, LIGHT_COLOR.a);
    }
}
 
void fragment() {   
    // Starting point for ray cast
    vec3 p = vec3(UV, getHeightRaw(UV));
    
    float minStepSize = min(pix.x, pix.y);
    
    // Direction of raycast is towards the sun from centre of screen
    //vec3 sunDir = vec3(rotateUVmatrinx(sunPos.xy,vec2(0.5)), sunPos.z);
    
    vec3 sunDir = sunPos;
    vec3 stepDir = normalize(sunDir);
    if (p.x > float(xframe+1)*xframe_size){
        p.z = .1;
    } else if (p.x < float(xframe)*xframe_size) {
        p.z = .1;
    } else if (p.y > float(yframe+1)*yframe_size){
        p.z = .1;
    } else if (p.y < float(yframe)*yframe_size) {
        p.z = .1;
    }
        
    float inShadow = 0.;
    int n = 0;
    
    for(int i = 1; i <= MAX_STEPS; i ++) {
        n++;
        
        // Check height at new location
        float h = getHeightRaw(p.xy);
 
        if(h > p.z && n > 0) {
            // ray is inside the terrain
            // therefore must be in shadow
            inShadow = 1.;
            
            if (p.x > float(xframe+1)*xframe_size){
                inShadow = 0.;
                break;
            } else if (p.x < float(xframe)*xframe_size) {
                inShadow = 0.;
                break;
            } else if (p.y > float(yframe+1)*yframe_size){
                inShadow = 0.;
                break;
            } else if (p.y < float(yframe)*yframe_size) {
                inShadow = 0.;
                break;
            }
            break;
        }
        if(p.z > 1.) {
            // above the heighest terrain level
            // will not be in shadow
            break;
        }
        
        // Step towards the sun by dist to heightmap
        p += stepDir * max(minStepSize, (p.z - h) * 0.05);
    }
    
    vec4 col = texture(TEXTURE, UV);
    
    vec4 emission_color = texture(emission_teture,UV); // what's our current emission pixel
    
    if (UV.x > float(xframe+1)*xframe_size){
        emission_color = vec4(0.);
    } else if (UV.x < float(xframe)*xframe_size) {
        emission_color = vec4(0.);
    } else if (UV.y > float(yframe+1)*yframe_size){
        emission_color = vec4(0.);
    } else if (UV.y < float(yframe)*yframe_size) {
        emission_color = vec4(0.);
    }
    
    if(emission_color.r > 0.) // check if we're not black in the emission color.
    {
        col += (emission_color * glow_color);
    }
    
    float normalShadow;
    if (UV.x > float(xframe+1)*xframe_size){
        col = vec4(0.);
        normalShadow = 0.;
    } else if (UV.x < float(xframe)*xframe_size) {
        col = vec4(0.);
        normalShadow = 0.;
    } else if (UV.y > float(yframe+1)*yframe_size){
        col = vec4(0.);
        normalShadow = 0.;
    } else if (UV.y < float(yframe)*yframe_size) {
        col = vec4(0.);
        normalShadow = 0.;
    } else {
        normalShadow = (dot(NORMAL, -stepDir) + 1.)/2.;
    }
    
    float distance_cut_off = 50.0; //px 
    vec2 at = screen_uv_to_sdf(SCREEN_UV);
    float temp = 1.-texture_sdf(at)/distance_cut_off;
    if (texture_sdf(at) > distance_cut_off) {
        temp = 0.;
    }
    
    inShadow = clamp(inShadow + normalShadow, 0., 1.)*temp;
    vec4 shadowCol = col * shadowBrightness * vec4(1.);
    shadowCol.a = 1.;
    // Create a darker version of the colour for the shadows (blue shifted);
    if (col.a < 0.1) {
        shadowCol = vec4(.0, .0, .0 , .75)*temp;
    }
    if (shadowCol.a < 0.1){
        shadowCol.a = 0.0;
    }   
    
    col = mix(col, shadowCol, inShadow);
    
    COLOR = col*modulate_color;
}
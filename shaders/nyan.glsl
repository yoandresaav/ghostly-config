
// -- CONFIGURATION --
const float DURATION = 0.2; 
const float MAX_TRAIL_LENGTH = 0.2;
const float THRESHOLD_MIN_DISTANCE = 0.5; // Reduced threshold to show trail more often
const float BLUR = 2.0; 

// --- CONSTANTS ---
const float PI = 3.14159265359;

// --- UTILS ---
vec2 normalize_coords(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
	return 1. - smoothstep(0., normalize_coords(vec2(BLUR, BLUR), 0.).x, distance);
}

// SDF Functions
float sdBox(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdCircle(vec2 p, float r) {
    return length(p) - r;
}

// Draw Nyan Cat
// p is relative to the center of the cursor
// size is the size of the cursor (width, height)
vec4 drawNyanCat(vec2 p, vec2 size) {
    vec4 color = vec4(0.0);
    
    // Scale cat relative to cursor width
    float scale = size.x * 2.25; // Reduced by another 5% (was 2.4)
    vec2 catP = p / scale;

    // --- FIXES ---
    // 1. Flip Y to fix "legs up" (Invert Y)
    catP.y = -catP.y; 
    
    // 2. Adjust Position
    // Vertical: Center it (remove large offset)
    catP.y += 0.0; 
    
    // Horizontal: Move MORE to the right (was 0.4)
    catP.x -= 0.75; 

    // Bobbing animation
    catP.y += sin(iTime * 15.0) * 0.05;

    // 1. Pop-Tart Body (Pink)
    // Rectangle body
    float body = sdBox(catP, vec2(0.5, 0.35));
    float bodyAlpha = 1.0 - smoothstep(0.0, 0.02, body);
    if (bodyAlpha > 0.0) {
        color = mix(color, vec4(0.98, 0.6, 0.65, 1.0), bodyAlpha); // Pink tart
        
        // Biscuit edge (Beige)
        float innerBody = sdBox(catP, vec2(0.42, 0.28));
        float biscuitAlpha = (1.0 - smoothstep(0.0, 0.02, body)) - (1.0 - smoothstep(0.0, 0.02, innerBody));
        color = mix(color, vec4(1.0, 0.8, 0.4, 1.0), biscuitAlpha);
        
        // Sprinkles (Simple dots)
        // Red sprinkles
        if (length(catP - vec2(-0.2, 0.1)) < 0.04) color = vec4(1.0, 0.2, 0.2, 1.0);
        if (length(catP - vec2(0.1, -0.15)) < 0.04) color = vec4(1.0, 0.2, 0.2, 1.0);
        // Pink sprinkles
        if (length(catP - vec2(0.2, 0.2)) < 0.04) color = vec4(1.0, 0.4, 0.8, 1.0);
    }

    // 2. Head (Grey)
    vec2 headP = catP - vec2(0.35, 0.1);
    float head = sdCircle(headP, 0.25);
    float headAlpha = 1.0 - smoothstep(0.0, 0.02, head);
    if (headAlpha > 0.0) {
        color = mix(color, vec4(0.6, 0.6, 0.6, 1.0), headAlpha); // Grey
        
        // Ears
        vec2 ear1 = abs(headP - vec2(-0.15, 0.15)) - vec2(0.05);
        vec2 ear2 = abs(headP - vec2(0.15, 0.15)) - vec2(0.05);
        if (max(ear1.x, ear1.y) < 0.0 || max(ear2.x, ear2.y) < 0.0) {
             color = mix(color, vec4(0.6, 0.6, 0.6, 1.0), 1.0);
        }
        
        // Eyes
        if (length(headP - vec2(-0.11, 0.05)) < 0.04) color = vec4(0.0, 0.0, 0.0, 1.0);
        if (length(headP - vec2(0.11, 0.05)) < 0.04) color = vec4(0.0, 0.0, 0.0, 1.0);
        
        // Cheeks
        if (length(headP - vec2(-0.18, -0.05)) < 0.04) color = vec4(1.0, 0.5, 0.5, 1.0);
        if (length(headP - vec2(0.18, -0.05)) < 0.04) color = vec4(1.0, 0.5, 0.5, 1.0);
        
        // Nose/Mouth area
         if (length(headP - vec2(0.0, -0.05)) < 0.02) color = vec4(0.0, 0.0, 0.0, 1.0);
    }
    
    // 3. Tail (Grey)
    vec2 tailP = catP - vec2(-0.55, 0.0);
    float tail = sdBox(tailP, vec2(0.1, 0.05));
     // Wiggle tail
    tailP.y += sin(iTime * 20.0) * 0.05;
    if (sdBox(tailP, vec2(0.1, 0.05)) < 0.0) {
        color = vec4(0.6, 0.6, 0.6, 1.0);
    }
    
    // 4. Feet (Grey)
    // Simple feet
    vec2 feetP = catP;
    feetP.y += 0.35; // Shift down
    feetP.x = mod(feetP.x + 0.1, 0.4) - 0.2; // Repeat feet
    // Only show feet within body width
    if (abs(catP.x) < 0.4 && sdBox(feetP, vec2(0.05, 0.08)) < 0.0) {
         // Feet animation
         float legOffset = sin(iTime * 20.0 + catP.x * 10.0) * 0.05;
         if (feetP.y + legOffset < 0.0)
            color = vec4(0.6, 0.6, 0.6, 1.0);
    }


    return color;
}

// Rainbow function
vec3 rainbow(float t) {
    return 0.5 + 0.5 * cos(6.28318 * (t + vec3(0.0, 0.33, 0.67)));
}

// Easing
float ease(float x) {
    return sqrt(1.0 - pow(x - 1.0, 2.0));
}

// SDF Helpers for Trail
float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

float getSdfRectangle(in vec2 p, in vec2 xy, in vec2 b) {
    vec2 d = abs(p - xy) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float determineIfTopRightIsLeading(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y); 
    float condition2 = step(a.x, b.x) * step(b.y, a.y); 
    return 1.0 - max(condition1, condition2);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    // Normalization
    vec2 vu = normalize_coords(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);
    
    vec4 currentCursor = vec4(normalize_coords(iCurrentCursor.xy, 1.), normalize_coords(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize_coords(iPreviousCursor.xy, 1.), normalize_coords(iPreviousCursor.zw, 0.));

    // --- CURSOR STYLE CHECK (DISABLED) ---
    // The detection logic was inconsistent across environments.
    // Commenting out to ensure the Nyan Cat is always visible for now.
    /*
    if (currentCursor.z < 0.015) {
        float barWidth = currentCursor.z;
        barWidth = max(barWidth, 0.004);
        vec2 barCenter = vec2(currentCursor.x + barWidth * 0.5, currentCursor.y - currentCursor.w * 0.5);
        float sdfBar = sdBox(vu - barCenter, vec2(barWidth * 0.5, currentCursor.w * 0.5));
        float barAlpha = antialising(sdfBar);
        fragColor = mix(fragColor, vec4(1.0, 1.0, 1.0, 1.0), barAlpha);
        return;
    }
    */

    vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor);
    vec2 centerCP = previousCursor.xy - (previousCursor.zw * offsetFactor);

    vec4 finalColor = fragColor;

    // --- 1. RAINBOW TRAIL ---
    vec2 delta = centerCP - centerCC;
    float lineLength = length(delta);
    float minDist = currentCursor.w * THRESHOLD_MIN_DISTANCE;
    
    if (lineLength > minDist) {
        float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
        float head_eased = 1.0; // Keep head attached to cursor
        float tail_eased = ease(progress);

         // detect straight moves
        vec2 delta_abs = abs(centerCC - centerCP); 
        float threshold = 0.001;
        float isHorizontal = step(delta_abs.y, threshold);
        float isVertical = step(delta_abs.x, threshold);
        float isStraightMove = max(isHorizontal, isVertical);

        // Parallelogram (Diagonal)
        vec2 head_pos_tl = mix(previousCursor.xy, currentCursor.xy, head_eased);
        vec2 tail_pos_tl = mix(previousCursor.xy, currentCursor.xy, tail_eased);
        float isTopRightLeading = determineIfTopRightIsLeading(currentCursor.xy, previousCursor.xy);
        float isBottomLeftLeading = 1.0 - isTopRightLeading;
        vec2 v0 = vec2(head_pos_tl.x + currentCursor.z * isTopRightLeading, head_pos_tl.y - currentCursor.w);
        vec2 v1 = vec2(head_pos_tl.x + currentCursor.z * isBottomLeftLeading, head_pos_tl.y);
        vec2 v2 = vec2(tail_pos_tl.x + currentCursor.z * isBottomLeftLeading, tail_pos_tl.y);
        vec2 v3 = vec2(tail_pos_tl.x + currentCursor.z * isTopRightLeading, tail_pos_tl.y - previousCursor.w);
        float sdfTrail_diag = getSdfParallelogram(vu, v0, v1, v2, v3);

        // Rectangle (Straight)
        vec2 head_center = mix(centerCP, centerCC, head_eased);
        vec2 tail_center = mix(centerCP, centerCC, tail_eased);
        vec2 min_center = min(head_center, tail_center);
        vec2 max_center = max(head_center, tail_center);
        vec2 box_size = (max_center - min_center) + currentCursor.zw;
        vec2 box_center = (min_center + max_center) * 0.5;
        float sdfTrail_rect = getSdfRectangle(vu, box_center, box_size * 0.5);

        float sdfTrail = mix(sdfTrail_diag, sdfTrail_rect, isStraightMove);
        
        // Rainbow Pattern for Trail
        // Based on x position and time
        vec3 rain = rainbow(vu.x * 3.0 - iTime * 5.0);
        vec4 trailColor = vec4(rain, 0.7); // 0.7 Alpha for trail
        
        float trailAlpha = antialising(sdfTrail);
        finalColor = mix(finalColor, trailColor, trailAlpha);
    }
    
    // --- 2. NYAN CAT ---
    // Draw cat at current cursor position (centerCC)
    // Scale depends on cursor size (currentCursor.zw)
    
    // Stabilize cursor size:
    // FORCE a fixed size constant. Do NOT use currentCursor.zw which changes on focus loss.
    // This ensures the cat is identical size/position regardless of focus state.
    vec2 cursorSize = vec2(0.04, 0.08); 
    
    vec4 catColor = drawNyanCat(vu - centerCC, cursorSize);
    
    // --- SMART TRANSPARENCY ---
    // Detect if we are covering text (assuming dark background)
    // If pixel luminosity is high (text), reduce cat opacity significantly (to 0.05)
    float textBrightness = length(finalColor.rgb);
    float opacity = mix(0.9, 0.05, smoothstep(0.1, 0.5, textBrightness));

    // Composite Cat over Trail/Terminal
    finalColor = mix(finalColor, catColor, catColor.a * opacity);

    fragColor = finalColor;
}

# Performance Analysis - Wolfenstein 3D macOS (17 FPS)

## Current Performance Bottlenecks

### 1. **Single-threaded Rendering (CRITICAL)**
- All 640 columns rendered sequentially on one thread
- Each column requires: raycasting + texture sampling + pixel drawing
- At 640x480: 307,200 pixels processed per frame

### 2. **Inefficient Texture Sampling**
- Per-pixel texture sampling with floating-point calculations
- No texture column caching
- Redundant modulo and clamping operations per pixel

### 3. **Excessive Memory Operations**
- CGContext creation for every frame
- Array copying in getPixelData()
- No pixel buffer reuse between frames

### 4. **Suboptimal Drawing Pipeline**
- NSImage creation from CGImage for every frame
- Unnecessary color space conversions
- GameView using drawRect instead of CALayer

### 5. **Floating-Point Heavy Operations**
- Texture coordinate calculations per pixel
- Wall distance calculations using doubles
- No SIMD optimizations

### 6. **Inefficient Column Rendering**
- Individual setPixel calls for textured walls
- No batch operations for vertical lines
- Redundant bounds checking per pixel

## Performance Improvements Plan

### Phase 1: Parallel Rendering (High Priority)
1. Split screen into vertical strips (8-16 strips)
2. Use DispatchQueue.concurrentPerform for parallel column rendering
3. Each thread renders a range of columns independently
4. Expected improvement: 3-4x speedup on M1 (8 cores)

### Phase 2: Texture Optimization (High Priority)
1. Pre-calculate texture columns at load time
2. Cache frequently used texture samples
3. Use integer math for texture coordinates
4. Implement texture atlasing

### Phase 3: Direct Metal/CALayer Rendering (Medium Priority)
1. Replace NSImage with CALayer + IOSurface
2. Direct pixel buffer updates without CGContext
3. Use CVPixelBuffer for zero-copy display

### Phase 4: SIMD Optimizations (Medium Priority)
1. Use SIMD for ray calculations
2. Batch pixel operations
3. Vectorize color calculations

### Phase 5: Memory Optimization (Low Priority)
1. Reuse pixel buffers
2. Eliminate intermediate allocations
3. Use unsafe operations in hot paths

## Expected Results
- Phase 1: 17 FPS → 50-60 FPS
- Phase 2: Additional 20-30% improvement
- Phase 3: Stable 60+ FPS with lower CPU usage
- Phase 4-5: Further optimizations for 120+ FPS
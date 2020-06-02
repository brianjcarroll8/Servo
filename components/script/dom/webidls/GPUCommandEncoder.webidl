/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

// https://gpuweb.github.io/gpuweb/#gpucommandencoder
[Exposed=(Window, DedicatedWorker), Serializable, Pref="dom.webgpu.enabled"]
interface GPUCommandEncoder {
    GPURenderPassEncoder beginRenderPass(GPURenderPassDescriptor descriptor);
    GPUComputePassEncoder beginComputePass(optional GPUComputePassDescriptor descriptor = {});

    void copyBufferToBuffer(
        GPUBuffer source,
        GPUSize64 sourceOffset,
        GPUBuffer destination,
        GPUSize64 destinationOffset,
        GPUSize64 size);

    // void copyBufferToTexture(
    //     GPUBufferCopyView source,
    //     GPUTextureCopyView destination,
    //     GPUExtent3D copySize);

    // void copyTextureToBuffer(
    //     GPUTextureCopyView source,
    //     GPUBufferCopyView destination,
    //     GPUExtent3D copySize);

    // void copyTextureToTexture(
    //     GPUTextureCopyView source,
    //     GPUTextureCopyView destination,
    //     GPUExtent3D copySize);

    // void pushDebugGroup(DOMString groupLabel);
    // void popDebugGroup();
    // void insertDebugMarker(DOMString markerLabel);

    GPUCommandBuffer finish(optional GPUCommandBufferDescriptor descriptor = {});
};
GPUCommandEncoder includes GPUObjectBase;

dictionary GPUComputePassDescriptor : GPUObjectDescriptorBase {
};

dictionary GPUCommandBufferDescriptor : GPUObjectDescriptorBase {
};

dictionary GPURenderPassDescriptor : GPUObjectDescriptorBase {
    required sequence<GPURenderPassColorAttachmentDescriptor> colorAttachments;
    GPURenderPassDepthStencilAttachmentDescriptor depthStencilAttachment;
    //GPUQuerySet occlusionQuerySet;
};

dictionary GPURenderPassColorAttachmentDescriptor {
    required GPUTextureView attachment;
    GPUTextureView resolveTarget;

    required (GPULoadOp or GPUColor) loadValue;
    GPUStoreOp storeOp = "store";
};

dictionary GPURenderPassDepthStencilAttachmentDescriptor {
    required GPUTextureView attachment;

    required (GPULoadOp or float) depthLoadValue;
    required GPUStoreOp depthStoreOp;
    boolean depthReadOnly = false;

    required GPUStencilLoadValue stencilLoadValue;
    required GPUStoreOp stencilStoreOp;
    boolean stencilReadOnly = false;
};

typedef (GPULoadOp or GPUStencilValue) GPUStencilLoadValue;

enum GPULoadOp {
    "load"
};

enum GPUStoreOp {
    "store",
    "clear"
};

dictionary GPUColorDict {
    required double r;
    required double g;
    required double b;
    required double a;
};
typedef (sequence<double> or GPUColorDict) GPUColor;

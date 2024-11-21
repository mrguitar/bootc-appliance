# Example appliance using [Image mode for RHEL](red.ht/imagemode)

This repo accompanies a blog on developers.redhat.com and includes two examples. [Containerfile.kiosk](Containerfile.kiosk) will build a very simple graphical system that displays a webpage with no human interaction. Kiosk deployments are incredibly useful for a broad range of use cases, so please change, adapt, and make this your own. This demo was adapted from [this post](https://www.redhat.com/en/blog/using-rhels-lightweight-kiosk-mode-edge-deployments) and [this bootc example](https://gitlab.com/fedora/bootc/examples/-/tree/main/kiosk?ref_type=heads).

The second example, [Containerfile.app](Containerfile.app), shows a basic system that runs a container as the primary workload. We're using Caddy as a simple web server for this example. While the example may not be super inspiring, this deployment pattern is very powerful. Things to note: Caddy is run via the caddy.container quadlet file. Notice that AutoUpdate=registry is enabled along with the podman-auto-update.timer. This means that podman will do regular check-ins on the registry and automatically update our primary workload on our behalf. Amazing! Also, we should reiterate that bootc defaults to automatically updating the system using the bootc-fetch-apply-updates.timer. In practice this means both our OS & primary workload will automatically update based on updates being available in the registry and using the same tags. Imagine automating your appliation and OS via the same container pipeline and an entire fleet of systems automatically updating. What a time to be alive!

# Steps
1. Setup a container build environment. While bootc is agnostic to any container runtime only Podman will automatically handle passing RHEL subscriptions into the container at build time, ensuring repo access. Basically, this demo will "just work" on the following environments: a RHEL 8 or newer system that is properly registered, a fedora system that is registered w/ subscription-manager, or a Mac or Windows system using Podman Desktop with the Red Hat Extension pack. Any valid RHEL subscription will work, including the no-cost developer one available [here.](https://developers.redhat.com/products/rhel/overview)
2. Accessing images on registry.redhat.io requires authentication. If you're using podman desktop w/ the Red Hat extension, it will handle the authentication for you and is our recommendation for new users. If you are using podman via the CLI, simply create a [service account](https://access.redhat.com/terms-based-registry/) and login. Note that creating an ISO will require running podman with sudo permissions. We recommend authenticating with the registry using `sudo podman`. If you need further help with the registry look [here](https://access.redhat.com/RegistryAuthentication#registry-service-accounts-for-shared-environments-4).
3. Clone this repo & `cd bootc-appliance`
4. To build the the graphical kiosk image run: `podman build -f Containerfile.kiosk -t [registry]/[account]/[image]:[tag]`. If you'd prefer to look at the container example using `Containerfile.app` in the previous command.
5. Update the config.toml file to match the container registry link you wish your production systems to update from.
6. Next create an iso to deploy the image we created:
   ```
   sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    -v $(pwd)/config.toml:/config.toml:ro \
    -v $(pwd)/output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    registry.redhat.io/rhel9/bootc-image-builder:latest \
    --type anaconda-iso \
    --local \
    [registry]/[account]/[image]:[tag]
   ```
   Our example intentionally creates an interactive install, and this is highly configurable if you desire to remove any of the options, or automate the install, it's all possible and fairly straight forward. Check this [link](https://github.com/osbuild/bootc-image-builder?tab=readme-ov-file#anaconda-iso-installer-options-installer-mapping) for details.
7. Install your system using an out-of-band management port, USB drive, PXE, vSphere - really any way you like.
8. Profitt!!!! Seriously Image mode provides an amazing developer experience to create & iterate on systems. They are incredibly easy to deploy in just about any environment, and managing systems via a pipeline and registry has never been easier.
   
### Usefull links
+ [Image mode for RHEL](red.ht/imagemode)
+ [Documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_image_mode_for_rhel_to_build_deploy_and_manage_operating_systems/introducing-image-mode-for-rhel_using-image-mode-for-rhel-to-build-deploy-and-manage-operating-systems#introducing-image-mode-for-rhel_using-image-mode-for-rhel-to-build-deploy-and-manage-operating-systems)

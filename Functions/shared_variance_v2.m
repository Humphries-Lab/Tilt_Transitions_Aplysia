function V=shared_variance_v2(C,D,singv,ndim)
%This version receives as inupt C (covariance and singv (its singular
%values)
%From Elsayed
%C is the cov(r_train)
%D are the PCs
%singv=flipud(eig(C));
V= trace(D'*C*D)/sum(singv(1:ndim));
%V=1-norm(R-R*(W*W'),'fro')/norm(R,'fro');
end
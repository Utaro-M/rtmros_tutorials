(load "package://hrpsys_ros_bridge/euslisp/rtm-ros-robot-interface.l")
(load "package://dynamixel_hand/euslisp/dxl-hand-interface.l")

(defclass jaxon-common-interface
  :super rtm-ros-robot-interface
  :slots (hand-enable)
  )

(defmethod jaxon-common-interface
  (:init
   (&rest args &key ((:robot rb)) ((:controller-timeout ct) nil))
   (prog1
       (send-super* :init :robot rb :controller-timeout ct args)
     ;; add controller
     (print ";; Add controllers")
     (dxl-hand-init)
     ))
  (:start-grasp
   (arm &rest args)
   (if hand-enable
       (hand-grasp arm)
     (warn ";; can not use hand~%")))
  (:stop-grasp
   (&rest args)
   (if hand-enable
       (hand-open arm)
     (warn ";; can not use hand~%")))
  (:hand-reset
   ;; (&rest args)
   (arm &rest args)
   (if hand-enable
       (hand-reset arm)
       ;; (send* (send self :get :hand-controller) :reset args)
     (warn ";; can not use hand~%")))
  (:get-joint-angle
   (arm &rest args)
   (if hand-enable
       (if (memq arm '(:rarm :larm :arms))
           (case
            arm
            (:rarm
             (send *rhand-ri* :angle-vector))
            (:larm
             (send *lhand-ri* :angle-vector))
            (:arms
             '((send *rhand-ri* :angle-vector)
               (send *lhand-ri* :angle-vector))))
         (error ";; no such arm in :gripper ~A~%" arm))
     (warn ";; can not use hand~%")))
)

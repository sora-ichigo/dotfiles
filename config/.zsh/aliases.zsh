alias v='LANG=C nvim'
alias g='git'
alias tf='terraform'
alias re='source ~/.zshrc'
alias mkdir='mkdir -p'
alias ls='ls -l -a'
alias fd='fd -H'
alias valec='AWS_SDK_LOAD_CONFIG=1 valec'
alias rmf='rm $(fd|fzf)'
alias lg='lazygit'

alias ec2-ubuntu-start="
  aws ec2 start-instances --instance-ids i-045d4a6f5bf5315ed \
  && aws ec2 wait instance-running --instance-ids i-045d4a6f5bf5315ed \
  && aws ec2 describe-instances --instance-ids i-045d4a6f5bf5315ed \
  | jq '.Reservations[].Instances[] | \
  {InstanceId, InstanceState: .State.Name, PublicDnsName, PublicIpAddress}'
"

alias ec2-ubuntu-stop="
  aws ec2 stop-instances --instance-ids i-045d4a6f5bf5315ed \
  && aws ec2 wait instance-stopped --instance-ids  i-045d4a6f5bf5315ed \
  && aws ec2 describe-instances --instance-ids i-045d4a6f5bf5315ed \
  | jq '.Reservations[].Instances[] | {InstanceId, Name, InstanceState: .State}'
  "

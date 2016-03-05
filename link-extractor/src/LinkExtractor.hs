import System.Posix.Unistd

main = do
  sleep 1
  putStrLn "Foobar"
  main
